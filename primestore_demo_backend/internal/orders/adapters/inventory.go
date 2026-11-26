package adapters

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"sort"
	"time"

	"github.com/lib/pq"

	db "primestore_demo_backend/db/sqlc"
	"primestore_demo_backend/internal/orders"
	"primestore_demo_backend/internal/orders/domain"
)

const (
	reservationReserved  = "reserved"
	reservationCommitted = "committed"
	reservationReleased  = "released"

	pgForeignKeyViolation = "23503"
)

// InventoryAdapter implements orders.Inventory on top of product_variants.stock
// and the stock_reservations table (stage 1: same database, separate module).
type InventoryAdapter struct {
	conn       *sql.DB
	q          *db.Queries
	ttlSeconds int32
}

var _ orders.Inventory = (*InventoryAdapter)(nil)

// NewInventoryAdapter creates the adapter. ttl is how long a reservation holds
// stock before the sweeper may release it (at least one second).
func NewInventoryAdapter(conn *sql.DB, ttl time.Duration) *InventoryAdapter {
	secs := int32(ttl / time.Second)
	if secs < 1 {
		secs = 1
	}
	return &InventoryAdapter{conn: conn, q: db.New(conn), ttlSeconds: secs}
}

// Reserve takes stock for every item or for none of them.
func (a *InventoryAdapter) Reserve(ctx context.Context, ref string, items []orders.ReserveItem) error {
	if ref == "" {
		return errors.New("reserve: empty reservation ref")
	}
	if len(items) == 0 {
		return errors.New("reserve: no items")
	}

	// Lock rows in a fixed order (ascending variant id). Two checkouts that touch
	// the same variants in different orders could otherwise deadlock.
	sorted := make([]orders.ReserveItem, len(items))
	copy(sorted, items)
	sort.Slice(sorted, func(i, j int) bool { return sorted[i].VariantID < sorted[j].VariantID })

	for i, it := range sorted {
		if it.Quantity < 1 {
			return fmt.Errorf("variant %d: %w", it.VariantID, domain.ErrQuantityLimit)
		}
		if i > 0 && sorted[i-1].VariantID == it.VariantID {
			return fmt.Errorf("variant %d: %w", it.VariantID, domain.ErrDuplicateVariant)
		}
	}

	tx, err := a.conn.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("reserve: begin transaction: %w", err)
	}
	defer tx.Rollback() // no-op after a successful Commit

	q := a.q.WithTx(tx)
	for _, it := range sorted {
		if err := a.reserveOne(ctx, q, ref, it); err != nil {
			return err // the deferred Rollback undoes every earlier item too
		}
	}

	if err := tx.Commit(); err != nil {
		return fmt.Errorf("reserve: commit: %w", err)
	}
	return nil
}

func (a *InventoryAdapter) reserveOne(ctx context.Context, q *db.Queries, ref string, it orders.ReserveItem) error {
	inserted, err := q.InsertReservation(ctx, db.InsertReservationParams{
		Ref:        ref,
		VariantID:  it.VariantID,
		Quantity:   it.Quantity,
		TtlSeconds: a.ttlSeconds,
	})
	if err != nil {
		var pqErr *pq.Error
		if errors.As(err, &pqErr) && pqErr.Code == pgForeignKeyViolation {
			return fmt.Errorf("variant %d: %w", it.VariantID, domain.ErrNotFound)
		}
		return fmt.Errorf("variant %d: insert reservation: %w", it.VariantID, err)
	}

	if inserted == 0 {
		// A row for (ref, variant) already exists, so this is a retry. Stock was
		// taken the first time: never take it again.
		existing, err := q.GetReservation(ctx, db.GetReservationParams{Ref: ref, VariantID: it.VariantID})
		if err != nil {
			return fmt.Errorf("variant %d: load existing reservation: %w", it.VariantID, err)
		}
		if existing.Quantity != it.Quantity {
			return fmt.Errorf("variant %d: reservation %q already exists with quantity %d, not %d",
				it.VariantID, ref, existing.Quantity, it.Quantity)
		}
		switch existing.Status {
		case reservationReserved, reservationCommitted:
			return nil
		default: // released: a released ref must never silently come back to life
			return fmt.Errorf("variant %d: %w", it.VariantID, domain.ErrReservationExpired)
		}
	}

	// The atomic step: the WHERE clause is the stock check, so two buyers can
	// never both take the last unit.
	taken, err := q.DecrementVariantStock(ctx, db.DecrementVariantStockParams{
		VariantID: it.VariantID,
		Quantity:  it.Quantity,
	})
	if err != nil {
		return fmt.Errorf("variant %d: decrement stock: %w", it.VariantID, err)
	}
	if taken == 0 {
		return &domain.OutOfStockError{VariantID: it.VariantID}
	}
	return nil
}

// Commit makes the reservation permanent. Calling it again on an already
// committed reservation succeeds.
func (a *InventoryAdapter) Commit(ctx context.Context, ref string) error {
	committed, err := a.q.CommitReservations(ctx, ref)
	if err != nil {
		return fmt.Errorf("commit reservation %q: %w", ref, err)
	}
	if committed > 0 {
		return nil
	}

	// Nothing was 'reserved'. Find out why.
	statuses, err := a.q.ListReservationStatuses(ctx, ref)
	if err != nil {
		return fmt.Errorf("commit reservation %q: %w", ref, err)
	}
	if len(statuses) == 0 {
		return fmt.Errorf("reservation %q: %w", ref, domain.ErrNotFound)
	}
	for _, s := range statuses {
		if s == reservationReleased {
			return fmt.Errorf("reservation %q: %w", ref, domain.ErrReservationExpired)
		}
	}
	return nil // already committed: a retry
}

// Release gives back the stock of every still-reserved row for ref. Calling it
// twice, or on a committed or unknown ref, does nothing.
func (a *InventoryAdapter) Release(ctx context.Context, ref string) error {
	tx, err := a.conn.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("release: begin transaction: %w", err)
	}
	defer tx.Rollback()

	q := a.q.WithTx(tx)

	released, err := q.ReleaseReservations(ctx, ref)
	if err != nil {
		return fmt.Errorf("release reservation %q: %w", ref, err)
	}

	// Same fixed lock order as Reserve.
	sort.Slice(released, func(i, j int) bool { return released[i].VariantID < released[j].VariantID })
	for _, r := range released {
		if err := q.IncrementVariantStock(ctx, db.IncrementVariantStockParams{
			VariantID: r.VariantID,
			Quantity:  r.Quantity,
		}); err != nil {
			return fmt.Errorf("release reservation %q: restock variant %d: %w", ref, r.VariantID, err)
		}
	}

	if err := tx.Commit(); err != nil {
		return fmt.Errorf("release reservation %q: commit: %w", ref, err)
	}
	return nil
}

// ReleaseExpired is the sweeper step: it releases reservations that were never
// committed and have expired. It returns how many checkouts (refs) it released.
// Phase 8 will call this on a timer.
func (a *InventoryAdapter) ReleaseExpired(ctx context.Context, maxRefs int32) (int, error) {
	refs, err := a.q.ListExpiredReservationRefs(ctx, maxRefs)
	if err != nil {
		return 0, fmt.Errorf("list expired reservations: %w", err)
	}

	released := 0
	for _, ref := range refs {
		if err := a.Release(ctx, ref); err != nil {
			return released, err
		}
		released++
	}
	return released, nil
}
