package service

import (
	"context"
	"errors"
	"regexp"
	"testing"
	"time"

	"primestore_demo_backend/internal/orders"
	"primestore_demo_backend/internal/orders/domain"
)

// ---- fakes (the cart store and catalog fakes live in cart_test.go) ---------

type idemKey struct {
	user int32
	key  string
}

type fakeOrderStore struct {
	cart *fakeCartStore

	nextID  int64
	orders  map[int64]domain.Order
	byKey   map[idemKey]int64
	numbers []string // the order number of every CreateOrder call

	createCalls int
	createErrs  []error // consumed in order, one per call; nil means "succeed"
	onCreate    func()  // runs at the start of every CreateOrder call

	// Simulates a parallel request that won the race for the same key: it is
	// returned by Find only after CreateOrder has been called at least once.
	raceOrder *domain.Order
}

func (f *fakeOrderStore) FindOrderByIdempotencyKey(_ context.Context, userID int32, key string) (domain.Order, error) {
	if id, ok := f.byKey[idemKey{userID, key}]; ok {
		return f.orders[id], nil
	}
	if f.raceOrder != nil && f.createCalls > 0 {
		return *f.raceOrder, nil
	}
	return domain.Order{}, domain.ErrNotFound
}

func (f *fakeOrderStore) CreateOrder(_ context.Context, order domain.Order, key string) (domain.Order, error) {
	f.createCalls++
	f.numbers = append(f.numbers, order.OrderNumber)
	if f.onCreate != nil {
		f.onCreate()
	}

	if len(f.createErrs) > 0 {
		err := f.createErrs[0]
		f.createErrs = f.createErrs[1:]
		if err != nil {
			return domain.Order{}, err
		}
	}
	if _, used := f.byKey[idemKey{order.UserID, key}]; used {
		return domain.Order{}, domain.ErrIdempotencyKeyReused
	}

	f.nextID++
	order.ID = f.nextID
	order.CreatedAt = time.Date(2026, 11, 17, 10, 0, 0, 0, time.UTC)
	f.orders[order.ID] = order
	f.byKey[idemKey{order.UserID, key}] = order.ID

	f.cart.ClearCart(context.Background(), order.UserID) // the real store does this in the same transaction
	return order, nil
}

type reserveCall struct {
	ref   string
	items []orders.ReserveItem
}

type fakeInventory struct {
	reserveErr     error
	reserved       []reserveCall
	released       []string
	releaseCtxErr  error // ctx.Err() as seen by Release
	commitAttempts int
	commitErrs     []error // consumed in order, one per attempt; nil means "succeed"
}

func (f *fakeInventory) Reserve(_ context.Context, ref string, items []orders.ReserveItem) error {
	f.reserved = append(f.reserved, reserveCall{ref: ref, items: items})
	return f.reserveErr
}

func (f *fakeInventory) Commit(_ context.Context, _ string) error {
	f.commitAttempts++
	if len(f.commitErrs) > 0 {
		err := f.commitErrs[0]
		f.commitErrs = f.commitErrs[1:]
		return err
	}
	return nil
}

func (f *fakeInventory) Release(ctx context.Context, ref string) error {
	f.released = append(f.released, ref)
	f.releaseCtxErr = ctx.Err()
	return nil
}

type addrKey struct {
	user int32
	id   int64
}

type fakeAddresses struct{ addrs map[addrKey]orders.Address }

func (f *fakeAddresses) Get(_ context.Context, userID int32, addressID int64) (orders.Address, error) {
	if a, ok := f.addrs[addrKey{userID, addressID}]; ok {
		return a, nil
	}
	return orders.Address{}, domain.ErrNotFound
}

// counterReader is a deterministic "random" source: 1, 2, 3, ... It never runs
// out, and every call gets different bytes, so order numbers differ per attempt.
type counterReader struct{ n byte }

func (r *counterReader) Read(p []byte) (int, error) {
	for i := range p {
		r.n++
		p[i] = r.n
	}
	return len(p), nil
}

// ---- fixture ---------------------------------------------------------------

const (
	testAddressID  int64 = 5
	testKey              = "key-12345678"
	testDeliveryFee      = "500.00"
)

type checkoutFixture struct {
	svc     *CheckoutService
	cart    *fakeCartStore
	orders  *fakeOrderStore
	inv     *fakeInventory
	addrs   *fakeAddresses
	catalog *fakeCatalog
}

func newCheckoutFixture(t *testing.T) *checkoutFixture {
	t.Helper()

	cart := newFakeCartStore()
	catalog := &fakeCatalog{variants: map[int32]orders.VariantInfo{
		1: {VariantID: 1, ProductID: 10, SellerID: 3, ProductName: "Shirt", Color: "Red", Size: "M",
			ImageURL: "https://img/shirt.jpg", UnitPrice: money(t, "1500.00"), Stock: 10},
		2: {VariantID: 2, ProductID: 20, ProductName: "Cap", UnitPrice: money(t, "499.99"), Stock: 5},
	}}
	store := &fakeOrderStore{cart: cart, orders: map[int64]domain.Order{}, byKey: map[idemKey]int64{}}
	inv := &fakeInventory{}
	addrs := &fakeAddresses{addrs: map[addrKey]orders.Address{
		{user, testAddressID}: {FullName: "Ada Lovelace", Phone: "0800000000", Line1: "1 Example Street",
			City: "Exampleville", State: "EX", PostalCode: "10001", Country: "Examplia"},
	}}

	svc := NewCheckoutService(
		CheckoutDeps{Cart: cart, Orders: store, Catalog: catalog, Inventory: inv, Addresses: addrs},
		CheckoutConfig{
			DeliveryFee: money(t, testDeliveryFee),
			Now:         func() time.Time { return time.Date(2026, 11, 17, 10, 0, 0, 0, time.UTC) },
			Random:      &counterReader{},
			Sleep:       func(time.Duration) {},
		},
	)
	return &checkoutFixture{svc: svc, cart: cart, orders: store, inv: inv, addrs: addrs, catalog: catalog}
}

// fill puts 2 shirts and 1 cap in the test user's cart.
func (fx *checkoutFixture) fill(t *testing.T) {
	t.Helper()
	ctx := context.Background()
	if _, err := fx.cart.UpsertCartItem(ctx, user, 1, 2, 10); err != nil {
		t.Fatal(err)
	}
	if _, err := fx.cart.UpsertCartItem(ctx, user, 2, 1, 10); err != nil {
		t.Fatal(err)
	}
}

func (fx *checkoutFixture) checkout() (CheckoutResult, error) {
	return fx.svc.Checkout(context.Background(), user, testAddressID, testKey)
}

// ---- tests -----------------------------------------------------------------

func TestCheckoutHappyPath(t *testing.T) {
	fx := newCheckoutFixture(t)
	fx.fill(t)

	res, err := fx.checkout()
	if err != nil {
		t.Fatalf("Checkout() error = %v", err)
	}
	o := res.Order

	if res.Replayed {
		t.Error("Replayed = true for a brand-new order")
	}
	if o.ID != 1 || o.UserID != user {
		t.Errorf("id/user = %d/%d, want 1/%d", o.ID, o.UserID, user)
	}
	if o.Status != domain.StatusPlaced || o.PaymentStatus != domain.PaymentUnpaid {
		t.Errorf("status = %s / %s, want placed / unpaid", o.Status, o.PaymentStatus)
	}
	if !regexp.MustCompile(`^PS-20261117-[A-HJ-NP-Z2-9]{6}$`).MatchString(o.OrderNumber) {
		t.Errorf("order number = %q, wrong format", o.OrderNumber)
	}
	if o.Subtotal != money(t, "3499.99") || o.DeliveryFee != money(t, "500.00") || o.Total != money(t, "3999.99") {
		t.Errorf("amounts = %s / %s / %s, want 3499.99 / 500.00 / 3999.99", o.Subtotal, o.DeliveryFee, o.Total)
	}

	if len(o.Items) != 2 {
		t.Fatalf("got %d items, want 2", len(o.Items))
	}
	shirt, hat := o.Items[0], o.Items[1]
	if shirt.ProductName != "Shirt" || shirt.VariantLabel != "Red / M" || shirt.ImageURL != "https://img/shirt.jpg" ||
		shirt.UnitPrice != money(t, "1500.00") || shirt.Quantity != 2 || shirt.LineTotal != money(t, "3000.00") ||
		shirt.SellerID != 3 || shirt.ProductID != 10 || shirt.VariantID != 1 {
		t.Errorf("shirt snapshot = %+v", shirt)
	}
	if hat.ProductName != "Cap" || hat.VariantLabel != "" || hat.UnitPrice != money(t, "499.99") {
		t.Errorf("cap snapshot = %+v", hat)
	}
	if o.Address.FullName != "Ada Lovelace" || o.Address.Line1 != "1 Example Street" || o.Address.Country != "Examplia" {
		t.Errorf("address snapshot = %+v", o.Address)
	}

	// The saga: stock reserved once for both items, then committed, never released.
	if len(fx.inv.reserved) != 1 {
		t.Fatalf("Reserve called %d times, want 1", len(fx.inv.reserved))
	}
	call := fx.inv.reserved[0]
	if len(call.items) != 2 || call.items[0] != (orders.ReserveItem{VariantID: 1, Quantity: 2}) ||
		call.items[1] != (orders.ReserveItem{VariantID: 2, Quantity: 1}) {
		t.Errorf("reserved items = %+v", call.items)
	}
	if o.StockRef == "" || o.StockRef != call.ref {
		t.Errorf("StockRef = %q, want the reserved ref %q", o.StockRef, call.ref)
	}
	if fx.inv.commitAttempts != 1 || len(fx.inv.released) != 0 {
		t.Errorf("commit attempts = %d, releases = %d, want 1 and 0", fx.inv.commitAttempts, len(fx.inv.released))
	}
	if len(fx.cart.qty) != 0 {
		t.Errorf("cart not emptied: %v", fx.cart.qty)
	}
}

func TestCheckoutUsesCatalogPricesNotCartData(t *testing.T) {
	fx := newCheckoutFixture(t)
	fx.fill(t)
	// The seller changes the price after the item was added to the cart.
	v := fx.catalog.variants[1]
	v.UnitPrice = money(t, "1200.00")
	fx.catalog.variants[1] = v

	res, err := fx.checkout()
	if err != nil {
		t.Fatalf("Checkout() error = %v", err)
	}
	if res.Order.Items[0].UnitPrice != money(t, "1200.00") {
		t.Errorf("unit price = %s, want the current catalog price 1200.00", res.Order.Items[0].UnitPrice)
	}
}

func TestCheckoutIsIdempotent(t *testing.T) {
	fx := newCheckoutFixture(t)
	fx.fill(t)

	first, err := fx.checkout()
	if err != nil {
		t.Fatalf("first Checkout() error = %v", err)
	}
	// The cart is now empty. A retry must still answer with the same order.
	second, err := fx.checkout()
	if err != nil {
		t.Fatalf("retry Checkout() error = %v", err)
	}

	if !second.Replayed || second.Order.ID != first.Order.ID || second.Order.OrderNumber != first.Order.OrderNumber {
		t.Errorf("retry = %+v (replayed %t), want the first order replayed", second.Order, second.Replayed)
	}
	if fx.orders.createCalls != 1 || len(fx.inv.reserved) != 1 {
		t.Errorf("create calls = %d, reserve calls = %d, want 1 and 1 (nothing new on a retry)",
			fx.orders.createCalls, len(fx.inv.reserved))
	}
}

func TestCheckoutIdempotencyKeysAreScopedPerUser(t *testing.T) {
	fx := newCheckoutFixture(t)
	fx.fill(t)
	if _, err := fx.checkout(); err != nil {
		t.Fatal(err)
	}

	// Another user with the same key must not see the first user's order.
	_, err := fx.svc.Checkout(context.Background(), user+1, testAddressID, testKey)
	if !errors.Is(err, domain.ErrEmptyCart) {
		t.Errorf("another user's checkout error = %v, want ErrEmptyCart (their own empty cart)", err)
	}
}

func TestCheckoutRaceWithTheSameKeyReturnsTheWinner(t *testing.T) {
	fx := newCheckoutFixture(t)
	fx.fill(t)
	winner := domain.Order{ID: 99, OrderNumber: "PS-20261117-WINNER", UserID: user}
	fx.orders.raceOrder = &winner
	fx.orders.createErrs = []error{domain.ErrIdempotencyKeyReused}

	res, err := fx.checkout()
	if err != nil {
		t.Fatalf("Checkout() error = %v", err)
	}

	if !res.Replayed || res.Order.ID != 99 {
		t.Errorf("result = %+v (replayed %t), want the winner's order", res.Order, res.Replayed)
	}
	if len(fx.inv.released) != 1 || fx.inv.commitAttempts != 0 {
		t.Errorf("releases = %d, commits = %d, want our reservation released and not committed",
			len(fx.inv.released), fx.inv.commitAttempts)
	}
}

func TestCheckoutRejectsBadInput(t *testing.T) {
	tests := []struct {
		name      string
		userID    int32
		addressID int64
		key       string
		wantErr   error
	}{
		{"invalid user", 0, testAddressID, testKey, domain.ErrInvalidUser},
		{"address id zero", user, 0, testKey, domain.ErrNotFound},
		{"empty key", user, testAddressID, "", domain.ErrInvalidIdempotencyKey},
		{"short key", user, testAddressID, "abc", domain.ErrInvalidIdempotencyKey},
		{"key with spaces", user, testAddressID, "key with spaces!", domain.ErrInvalidIdempotencyKey},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			fx := newCheckoutFixture(t)
			fx.fill(t)

			_, err := fx.svc.Checkout(context.Background(), tt.userID, tt.addressID, tt.key)

			if !errors.Is(err, tt.wantErr) {
				t.Errorf("Checkout() error = %v, want errors.Is(_, %v)", err, tt.wantErr)
			}
			if len(fx.inv.reserved) != 0 || fx.orders.createCalls != 0 {
				t.Error("nothing should have been reserved or created")
			}
		})
	}
}

func TestCheckoutFailuresBeforeReserveTouchNothing(t *testing.T) {
	t.Run("empty cart", func(t *testing.T) {
		fx := newCheckoutFixture(t)
		_, err := fx.checkout()
		if !errors.Is(err, domain.ErrEmptyCart) {
			t.Errorf("error = %v, want ErrEmptyCart", err)
		}
		if len(fx.inv.reserved) != 0 {
			t.Error("stock was reserved for an empty cart")
		}
	})

	t.Run("unknown address", func(t *testing.T) {
		fx := newCheckoutFixture(t)
		fx.fill(t)
		_, err := fx.svc.Checkout(context.Background(), user, 404, testKey)
		if !errors.Is(err, domain.ErrNotFound) {
			t.Errorf("error = %v, want ErrNotFound", err)
		}
		if len(fx.inv.reserved) != 0 {
			t.Error("stock was reserved for an unknown address")
		}
	})

	t.Run("someone else's address", func(t *testing.T) {
		fx := newCheckoutFixture(t)
		// The other user has a cart of their own, but the address belongs to `user`.
		if _, err := fx.cart.UpsertCartItem(context.Background(), user+1, 1, 1, 10); err != nil {
			t.Fatal(err)
		}

		_, err := fx.svc.Checkout(context.Background(), user+1, testAddressID, testKey)

		if !errors.Is(err, domain.ErrNotFound) {
			t.Errorf("error = %v, want ErrNotFound (an address that is not yours looks like a missing one)", err)
		}
		if len(fx.inv.reserved) != 0 {
			t.Error("stock was reserved")
		}
	})

	t.Run("variant deleted from the catalog", func(t *testing.T) {
		fx := newCheckoutFixture(t)
		fx.fill(t)
		delete(fx.catalog.variants, 1)

		_, err := fx.checkout()

		var unavailable *domain.ItemUnavailableError
		if !errors.Is(err, domain.ErrItemUnavailable) || !errors.As(err, &unavailable) || unavailable.VariantID != 1 {
			t.Errorf("error = %v, want ItemUnavailableError for variant 1", err)
		}
		if len(fx.inv.reserved) != 0 {
			t.Error("stock was reserved")
		}
	})

	t.Run("variant without a price", func(t *testing.T) {
		fx := newCheckoutFixture(t)
		fx.fill(t)
		v := fx.catalog.variants[2]
		v.UnitPrice = 0
		fx.catalog.variants[2] = v

		_, err := fx.checkout()

		if !errors.Is(err, domain.ErrItemUnavailable) {
			t.Errorf("error = %v, want ErrItemUnavailable", err)
		}
	})

	t.Run("catalog failure", func(t *testing.T) {
		fx := newCheckoutFixture(t)
		fx.fill(t)
		boom := errors.New("catalog down")
		fx.catalog.err = boom

		if _, err := fx.checkout(); !errors.Is(err, boom) {
			t.Errorf("error = %v, want it to wrap the catalog error", err)
		}
	})
}

func TestCheckoutOutOfStock(t *testing.T) {
	fx := newCheckoutFixture(t)
	fx.fill(t)
	fx.inv.reserveErr = &domain.OutOfStockError{VariantID: 2}

	_, err := fx.checkout()

	var oos *domain.OutOfStockError
	if !errors.Is(err, domain.ErrOutOfStock) || !errors.As(err, &oos) || oos.VariantID != 2 {
		t.Fatalf("error = %v, want OutOfStockError for variant 2", err)
	}
	if fx.orders.createCalls != 0 {
		t.Error("an order was created without stock")
	}
	if len(fx.cart.qty) != 2 {
		t.Errorf("cart was changed: %v", fx.cart.qty)
	}
	if len(fx.inv.released) != 0 {
		t.Error("Release called, but Reserve is atomic and left nothing behind")
	}
}

func TestCheckoutReserveReportsAVanishedVariant(t *testing.T) {
	fx := newCheckoutFixture(t)
	fx.fill(t)
	fx.inv.reserveErr = domain.ErrNotFound

	if _, err := fx.checkout(); !errors.Is(err, domain.ErrItemUnavailable) {
		t.Errorf("error = %v, want ErrItemUnavailable", err)
	}
}

func TestCheckoutReleasesStockWhenSavingFails(t *testing.T) {
	fx := newCheckoutFixture(t)
	fx.fill(t)
	boom := errors.New("database down")
	fx.orders.createErrs = []error{boom}

	_, err := fx.checkout()

	if !errors.Is(err, boom) {
		t.Errorf("error = %v, want it to wrap the store error", err)
	}
	if len(fx.inv.released) != 1 || fx.inv.released[0] != fx.inv.reserved[0].ref {
		t.Errorf("released = %v, want the reservation %q released", fx.inv.released, fx.inv.reserved[0].ref)
	}
	if fx.inv.commitAttempts != 0 {
		t.Error("a failed order was committed")
	}
	if len(fx.cart.qty) != 2 {
		t.Errorf("cart was changed: %v", fx.cart.qty)
	}
}

func TestCheckoutCompensatesEvenWhenTheClientDisconnects(t *testing.T) {
	fx := newCheckoutFixture(t)
	fx.fill(t)

	ctx, cancel := context.WithCancel(context.Background())
	fx.orders.onCreate = cancel // the client goes away while the order is being saved
	fx.orders.createErrs = []error{errors.New("connection lost")}

	if _, err := fx.svc.Checkout(ctx, user, testAddressID, testKey); err == nil {
		t.Fatal("Checkout() succeeded, want an error")
	}

	if len(fx.inv.released) != 1 {
		t.Fatalf("Release called %d times, want 1", len(fx.inv.released))
	}
	if fx.inv.releaseCtxErr != nil {
		t.Errorf("Release ran on a dead context (%v): stock would stay reserved", fx.inv.releaseCtxErr)
	}
}

func TestCheckoutRetriesOrderNumberCollisions(t *testing.T) {
	t.Run("recovers", func(t *testing.T) {
		fx := newCheckoutFixture(t)
		fx.fill(t)
		fx.orders.createErrs = []error{domain.ErrOrderNumberTaken, domain.ErrOrderNumberTaken, nil}

		res, err := fx.checkout()
		if err != nil {
			t.Fatalf("Checkout() error = %v", err)
		}

		if fx.orders.createCalls != 3 {
			t.Errorf("create calls = %d, want 3", fx.orders.createCalls)
		}
		seen := map[string]bool{}
		for _, n := range fx.orders.numbers {
			if seen[n] {
				t.Errorf("order number %q was reused after a collision", n)
			}
			seen[n] = true
		}
		if res.Order.OrderNumber != fx.orders.numbers[2] {
			t.Errorf("saved number = %q, want the third attempt's %q", res.Order.OrderNumber, fx.orders.numbers[2])
		}
		if len(fx.inv.released) != 0 {
			t.Error("stock was released although the order was saved")
		}
	})

	t.Run("gives up", func(t *testing.T) {
		fx := newCheckoutFixture(t)
		fx.fill(t)
		fx.orders.createErrs = []error{domain.ErrOrderNumberTaken, domain.ErrOrderNumberTaken, domain.ErrOrderNumberTaken}

		_, err := fx.checkout()

		if !errors.Is(err, domain.ErrOrderNumberTaken) {
			t.Errorf("error = %v, want ErrOrderNumberTaken", err)
		}
		if fx.orders.createCalls != maxOrderNumberAttempts {
			t.Errorf("create calls = %d, want %d", fx.orders.createCalls, maxOrderNumberAttempts)
		}
		if len(fx.inv.released) != 1 {
			t.Error("stock was not released after giving up")
		}
	})
}

func TestCheckoutCommitHandling(t *testing.T) {
	boom := errors.New("commit failed")

	t.Run("transient failures are retried", func(t *testing.T) {
		fx := newCheckoutFixture(t)
		fx.fill(t)
		fx.inv.commitErrs = []error{boom, boom, nil}

		if _, err := fx.checkout(); err != nil {
			t.Fatalf("Checkout() error = %v", err)
		}
		if fx.inv.commitAttempts != 3 {
			t.Errorf("commit attempts = %d, want 3", fx.inv.commitAttempts)
		}
	})

	t.Run("persistent failure still returns the real order", func(t *testing.T) {
		fx := newCheckoutFixture(t)
		fx.fill(t)
		fx.inv.commitErrs = []error{boom, boom, boom}

		res, err := fx.checkout()

		if err != nil {
			t.Fatalf("Checkout() error = %v, want success (the order exists and holds its stock)", err)
		}
		if res.Order.ID == 0 || fx.inv.commitAttempts != maxCommitAttempts {
			t.Errorf("order id = %d, commit attempts = %d", res.Order.ID, fx.inv.commitAttempts)
		}
		if len(fx.inv.released) != 0 {
			t.Error("the stock of a saved order was released")
		}
	})

	t.Run("an expired reservation is an error and is not retried", func(t *testing.T) {
		fx := newCheckoutFixture(t)
		fx.fill(t)
		fx.inv.commitErrs = []error{domain.ErrReservationExpired}

		_, err := fx.checkout()

		if !errors.Is(err, domain.ErrReservationExpired) {
			t.Errorf("error = %v, want ErrReservationExpired", err)
		}
		if fx.inv.commitAttempts != 1 {
			t.Errorf("commit attempts = %d, want 1 (expiry is final)", fx.inv.commitAttempts)
		}
	})
}
