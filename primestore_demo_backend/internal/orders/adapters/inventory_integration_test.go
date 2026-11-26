package adapters

// Integration tests: they need a real Postgres with all migrations applied.
// They are skipped unless TEST_DATABASE_URL is set. Run them with:
//
//	TEST_DATABASE_URL="postgresql://postgres:secret@localhost:5433/primestore?sslmode=disable" \
//	  go test ./internal/orders/adapters/ -run Inventory -race -count=1 -v
//
// Every test creates its own product and variant and deletes them afterwards
// (the cascade also removes the reservations).

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"os"
	"sync"
	"testing"
	"time"

	_ "github.com/lib/pq"

	"primestore_demo_backend/internal/orders"
	"primestore_demo_backend/internal/orders/domain"
)

func testDB(t *testing.T) *sql.DB {
	t.Helper()

	url := os.Getenv("TEST_DATABASE_URL")
	if url == "" {
		t.Skip("TEST_DATABASE_URL is not set, skipping integration test")
	}

	conn, err := sql.Open("postgres", url)
	if err != nil {
		t.Fatalf("sql.Open: %v", err)
	}
	conn.SetMaxOpenConns(40) // enough for the concurrent tests
	t.Cleanup(func() { conn.Close() })

	if err := conn.PingContext(context.Background()); err != nil {
		t.Fatalf("cannot reach the test database: %v", err)
	}
	return conn
}

// newTestVariant inserts a product with one variant holding the given stock.
func newTestVariant(t *testing.T, conn *sql.DB, stock int32) int32 {
	t.Helper()
	ctx := context.Background()

	var productID int32
	err := conn.QueryRowContext(ctx,
		`INSERT INTO products (name) VALUES ($1) RETURNING id`,
		fmt.Sprintf("inventory-test-%d", time.Now().UnixNano()),
	).Scan(&productID)
	if err != nil {
		t.Fatalf("insert test product: %v", err)
	}
	t.Cleanup(func() {
		conn.ExecContext(context.Background(), `DELETE FROM products WHERE id = $1`, productID)
	})

	var variantID int32
	err = conn.QueryRowContext(ctx,
		`INSERT INTO product_variants (product_id, price, stock) VALUES ($1, 10.00, $2) RETURNING id`,
		productID, stock,
	).Scan(&variantID)
	if err != nil {
		t.Fatalf("insert test variant: %v", err)
	}
	return variantID
}

func stockOf(t *testing.T, conn *sql.DB, variantID int32) int32 {
	t.Helper()
	var stock int32
	err := conn.QueryRowContext(context.Background(),
		`SELECT stock FROM product_variants WHERE id = $1`, variantID).Scan(&stock)
	if err != nil {
		t.Fatalf("read stock: %v", err)
	}
	return stock
}

func countReservations(t *testing.T, conn *sql.DB, variantID int32, status string) int {
	t.Helper()
	var n int
	err := conn.QueryRowContext(context.Background(),
		`SELECT count(*) FROM stock_reservations WHERE variant_id = $1 AND status = $2`,
		variantID, status).Scan(&n)
	if err != nil {
		t.Fatalf("count reservations: %v", err)
	}
	return n
}

func uniqueRef(prefix string) string {
	return fmt.Sprintf("%s-%d", prefix, time.Now().UnixNano())
}

func one(variantID, qty int32) []orders.ReserveItem {
	return []orders.ReserveItem{{VariantID: variantID, Quantity: qty}}
}

// The test that proves the design: many buyers, little stock, nobody oversells.
func TestInventoryConcurrentBuyersNeverOversell(t *testing.T) {
	for _, stock := range []int32{1, 5} {
		t.Run(fmt.Sprintf("stock_%d", stock), func(t *testing.T) {
			conn := testDB(t)
			inv := NewInventoryAdapter(conn, 15*time.Minute)
			variantID := newTestVariant(t, conn, stock)

			const buyers = 20
			start := make(chan struct{})
			results := make([]error, buyers)

			var wg sync.WaitGroup
			for i := 0; i < buyers; i++ {
				wg.Add(1)
				go func(i int) {
					defer wg.Done()
					<-start // everyone starts at the same moment
					results[i] = inv.Reserve(context.Background(),
						fmt.Sprintf("race-%d-%d", variantID, i), one(variantID, 1))
				}(i)
			}
			close(start)
			wg.Wait()

			succeeded := 0
			for i, err := range results {
				switch {
				case err == nil:
					succeeded++
				case errors.Is(err, domain.ErrOutOfStock):
					// expected for the losers
				default:
					t.Errorf("buyer %d: unexpected error: %v", i, err)
				}
			}

			if succeeded != int(stock) {
				t.Errorf("%d buyers succeeded, want exactly %d (the stock)", succeeded, stock)
			}
			if got := stockOf(t, conn, variantID); got != 0 {
				t.Errorf("stock after the rush = %d, want 0", got)
			}
			if got := countReservations(t, conn, variantID, "reserved"); got != int(stock) {
				t.Errorf("reserved rows = %d, want %d", got, stock)
			}
		})
	}
}

func TestInventoryReserveIsIdempotent(t *testing.T) {
	conn := testDB(t)
	inv := NewInventoryAdapter(conn, 15*time.Minute)
	variantID := newTestVariant(t, conn, 3)
	ref := uniqueRef("idem")
	ctx := context.Background()

	for attempt := 1; attempt <= 3; attempt++ {
		if err := inv.Reserve(ctx, ref, one(variantID, 2)); err != nil {
			t.Fatalf("attempt %d: Reserve() error = %v", attempt, err)
		}
	}

	if got := stockOf(t, conn, variantID); got != 1 {
		t.Errorf("stock = %d, want 1 (taken once, not once per retry)", got)
	}
	if got := countReservations(t, conn, variantID, "reserved"); got != 1 {
		t.Errorf("reserved rows = %d, want 1", got)
	}

	// Same ref with a different quantity is a bug in the caller: refuse it.
	if err := inv.Reserve(ctx, ref, one(variantID, 3)); err == nil {
		t.Error("Reserve() with a different quantity for the same ref succeeded, want an error")
	}
	if got := stockOf(t, conn, variantID); got != 1 {
		t.Errorf("stock changed after the refused call: %d, want 1", got)
	}
}

func TestInventoryReserveIsAllOrNothing(t *testing.T) {
	conn := testDB(t)
	inv := NewInventoryAdapter(conn, 15*time.Minute)
	plenty := newTestVariant(t, conn, 5)
	empty := newTestVariant(t, conn, 0)
	ref := uniqueRef("atomic")

	err := inv.Reserve(context.Background(), ref, []orders.ReserveItem{
		{VariantID: plenty, Quantity: 2},
		{VariantID: empty, Quantity: 1},
	})

	if !errors.Is(err, domain.ErrOutOfStock) {
		t.Fatalf("Reserve() error = %v, want ErrOutOfStock", err)
	}
	var oos *domain.OutOfStockError
	if !errors.As(err, &oos) || oos.VariantID != empty {
		t.Errorf("error should name variant %d, got %v", empty, err)
	}
	if got := stockOf(t, conn, plenty); got != 5 {
		t.Errorf("stock of the available variant = %d, want 5 (rolled back)", got)
	}
	if got := countReservations(t, conn, plenty, "reserved"); got != 0 {
		t.Errorf("reservation rows left behind = %d, want 0", got)
	}
}

func TestInventoryReserveUnknownVariant(t *testing.T) {
	conn := testDB(t)
	inv := NewInventoryAdapter(conn, 15*time.Minute)

	err := inv.Reserve(context.Background(), uniqueRef("ghost"), one(2147483000, 1))
	if !errors.Is(err, domain.ErrNotFound) {
		t.Errorf("Reserve() error = %v, want ErrNotFound", err)
	}
}

func TestInventoryReserveRejectsBadInput(t *testing.T) {
	conn := testDB(t)
	inv := NewInventoryAdapter(conn, 15*time.Minute)
	variantID := newTestVariant(t, conn, 5)
	ctx := context.Background()

	if err := inv.Reserve(ctx, uniqueRef("q0"), one(variantID, 0)); !errors.Is(err, domain.ErrQuantityLimit) {
		t.Errorf("quantity 0: error = %v, want ErrQuantityLimit", err)
	}
	dup := []orders.ReserveItem{{VariantID: variantID, Quantity: 1}, {VariantID: variantID, Quantity: 1}}
	if err := inv.Reserve(ctx, uniqueRef("dup"), dup); !errors.Is(err, domain.ErrDuplicateVariant) {
		t.Errorf("duplicate variant: error = %v, want ErrDuplicateVariant", err)
	}
	if err := inv.Reserve(ctx, "", one(variantID, 1)); err == nil {
		t.Error("empty ref: want an error")
	}
	if got := stockOf(t, conn, variantID); got != 5 {
		t.Errorf("stock = %d, want 5 (nothing should have been taken)", got)
	}
}

func TestInventoryReleaseRestoresStockAndIsIdempotent(t *testing.T) {
	conn := testDB(t)
	inv := NewInventoryAdapter(conn, 15*time.Minute)
	variantID := newTestVariant(t, conn, 5)
	ref := uniqueRef("rel")
	ctx := context.Background()

	if err := inv.Reserve(ctx, ref, one(variantID, 2)); err != nil {
		t.Fatalf("Reserve() error = %v", err)
	}
	if got := stockOf(t, conn, variantID); got != 3 {
		t.Fatalf("stock after reserve = %d, want 3", got)
	}

	for i := 1; i <= 2; i++ { // the second call must change nothing
		if err := inv.Release(ctx, ref); err != nil {
			t.Fatalf("Release() call %d error = %v", i, err)
		}
		if got := stockOf(t, conn, variantID); got != 5 {
			t.Errorf("stock after release call %d = %d, want 5", i, got)
		}
	}

	// A released ref must not come back to life.
	if err := inv.Reserve(ctx, ref, one(variantID, 2)); !errors.Is(err, domain.ErrReservationExpired) {
		t.Errorf("Reserve() after Release error = %v, want ErrReservationExpired", err)
	}
	if got := stockOf(t, conn, variantID); got != 5 {
		t.Errorf("stock after refused re-reserve = %d, want 5", got)
	}

	// Releasing an unknown ref is harmless.
	if err := inv.Release(ctx, uniqueRef("never-existed")); err != nil {
		t.Errorf("Release() of unknown ref error = %v, want nil", err)
	}
}

func TestInventoryCommit(t *testing.T) {
	conn := testDB(t)
	inv := NewInventoryAdapter(conn, 15*time.Minute)
	variantID := newTestVariant(t, conn, 5)
	ctx := context.Background()

	committed := uniqueRef("commit")
	if err := inv.Reserve(ctx, committed, one(variantID, 2)); err != nil {
		t.Fatalf("Reserve() error = %v", err)
	}
	if err := inv.Commit(ctx, committed); err != nil {
		t.Fatalf("Commit() error = %v", err)
	}
	if err := inv.Commit(ctx, committed); err != nil {
		t.Errorf("second Commit() error = %v, want nil (retry)", err)
	}

	// Releasing a committed reservation must NOT give the stock back.
	if err := inv.Release(ctx, committed); err != nil {
		t.Fatalf("Release() after Commit error = %v", err)
	}
	if got := stockOf(t, conn, variantID); got != 3 {
		t.Errorf("stock = %d, want 3 (committed stock stays taken)", got)
	}

	// Committing something that was already released is an error.
	released := uniqueRef("commit-late")
	if err := inv.Reserve(ctx, released, one(variantID, 1)); err != nil {
		t.Fatalf("Reserve() error = %v", err)
	}
	if err := inv.Release(ctx, released); err != nil {
		t.Fatalf("Release() error = %v", err)
	}
	if err := inv.Commit(ctx, released); !errors.Is(err, domain.ErrReservationExpired) {
		t.Errorf("Commit() after Release error = %v, want ErrReservationExpired", err)
	}

	// And an unknown ref is not found.
	if err := inv.Commit(ctx, uniqueRef("unknown")); !errors.Is(err, domain.ErrNotFound) {
		t.Errorf("Commit() of unknown ref error = %v, want ErrNotFound", err)
	}
}

func TestInventoryReleaseExpired(t *testing.T) {
	conn := testDB(t)
	inv := NewInventoryAdapter(conn, 15*time.Minute)
	variantID := newTestVariant(t, conn, 5)
	ctx := context.Background()

	stale := uniqueRef("stale")
	fresh := uniqueRef("fresh")
	if err := inv.Reserve(ctx, stale, one(variantID, 2)); err != nil {
		t.Fatalf("Reserve(stale) error = %v", err)
	}
	if err := inv.Reserve(ctx, fresh, one(variantID, 1)); err != nil {
		t.Fatalf("Reserve(fresh) error = %v", err)
	}
	if got := stockOf(t, conn, variantID); got != 2 {
		t.Fatalf("stock after reserving = %d, want 2", got)
	}

	// Pretend the first checkout was abandoned 20 minutes ago.
	_, err := conn.ExecContext(ctx,
		`UPDATE stock_reservations SET expires_at = now() - interval '20 minutes' WHERE ref = $1`, stale)
	if err != nil {
		t.Fatalf("age the reservation: %v", err)
	}

	n, err := inv.ReleaseExpired(ctx, 100)
	if err != nil {
		t.Fatalf("ReleaseExpired() error = %v", err)
	}
	if n < 1 {
		t.Errorf("ReleaseExpired() released %d refs, want at least 1", n)
	}

	if got := stockOf(t, conn, variantID); got != 4 {
		t.Errorf("stock = %d, want 4 (only the expired hold of 2 came back)", got)
	}
	if got := countReservations(t, conn, variantID, "reserved"); got != 1 {
		t.Errorf("reserved rows = %d, want 1 (the fresh one)", got)
	}
}
