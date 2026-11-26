package service

import (
	"context"
	"errors"
	"sort"
	"testing"

	"primestore_demo_backend/internal/orders"
	"primestore_demo_backend/internal/orders/domain"
)

// ---- fakes -----------------------------------------------------------------

type cartKey struct{ user, variant int32 }

type fakeCartStore struct {
	qty map[cartKey]int32
}

func newFakeCartStore() *fakeCartStore { return &fakeCartStore{qty: map[cartKey]int32{}} }

func (f *fakeCartStore) UpsertCartItem(_ context.Context, userID, variantID, quantity, maxQuantity int32) (int32, error) {
	k := cartKey{userID, variantID}
	n := f.qty[k] + quantity
	if n > maxQuantity { // same cap as the SQL LEAST(...)
		n = maxQuantity
	}
	f.qty[k] = n
	return n, nil
}

func (f *fakeCartStore) SetCartItemQuantity(_ context.Context, userID, variantID, quantity int32) (bool, error) {
	k := cartKey{userID, variantID}
	if _, ok := f.qty[k]; !ok {
		return false, nil
	}
	f.qty[k] = quantity
	return true, nil
}

func (f *fakeCartStore) RemoveCartItem(_ context.Context, userID, variantID int32) (bool, error) {
	k := cartKey{userID, variantID}
	if _, ok := f.qty[k]; !ok {
		return false, nil
	}
	delete(f.qty, k)
	return true, nil
}

func (f *fakeCartStore) ListCartItems(_ context.Context, userID int32) ([]domain.CartEntry, error) {
	var out []domain.CartEntry
	for k, q := range f.qty {
		if k.user == userID {
			out = append(out, domain.CartEntry{VariantID: k.variant, Quantity: q})
		}
	}
	sort.Slice(out, func(i, j int) bool { return out[i].VariantID < out[j].VariantID })
	return out, nil
}

func (f *fakeCartStore) ClearCart(_ context.Context, userID int32) error {
	for k := range f.qty {
		if k.user == userID {
			delete(f.qty, k)
		}
	}
	return nil
}

type fakeCatalog struct {
	variants map[int32]orders.VariantInfo
	err      error
}

func (f *fakeCatalog) GetVariants(_ context.Context, ids []int32) (map[int32]orders.VariantInfo, error) {
	if f.err != nil {
		return nil, f.err
	}
	out := make(map[int32]orders.VariantInfo)
	for _, id := range ids {
		if v, ok := f.variants[id]; ok {
			out[id] = v
		}
	}
	return out, nil
}

func money(t *testing.T, s string) domain.Money {
	t.Helper()
	m, err := domain.ParseMoney(s)
	if err != nil {
		t.Fatalf("ParseMoney(%q): %v", s, err)
	}
	return m
}

const user int32 = 7

// newTestService returns a service with two variants in the catalog:
//
//	1: Shirt, Red / M, 1500.00, stock 10
//	2: Cap,   no color/size, 499.99, stock 1
func newTestService(t *testing.T) (*Service, *fakeCartStore, *fakeCatalog) {
	t.Helper()
	store := newFakeCartStore()
	catalog := &fakeCatalog{variants: map[int32]orders.VariantInfo{
		1: {VariantID: 1, ProductID: 10, SellerID: 3, ProductName: "Shirt", Color: "Red", Size: "M",
			ImageURL: "https://img/shirt.jpg", UnitPrice: money(t, "1500.00"), Stock: 10},
		2: {VariantID: 2, ProductID: 20, ProductName: "Cap", UnitPrice: money(t, "499.99"), Stock: 1},
	}}
	return New(store, catalog), store, catalog
}

// ---- tests -----------------------------------------------------------------

func TestAddToCartAddsAndCaps(t *testing.T) {
	svc, _, _ := newTestService(t)
	ctx := context.Background()

	got, err := svc.AddToCart(ctx, user, 1, 3)
	if err != nil || got != 3 {
		t.Fatalf("first add = (%d, %v), want (3, nil)", got, err)
	}
	got, err = svc.AddToCart(ctx, user, 1, 9)
	if err != nil {
		t.Fatalf("second add error = %v", err)
	}
	if got != domain.MaxCartQuantity {
		t.Errorf("quantity after 3+9 = %d, want the cap %d", got, domain.MaxCartQuantity)
	}
}

func TestAddToCartRejectsBadInputWithoutTouchingTheStore(t *testing.T) {
	tests := []struct {
		name      string
		userID    int32
		variantID int32
		quantity  int32
		wantErr   error
	}{
		{"zero quantity", user, 1, 0, domain.ErrQuantityLimit},
		{"negative quantity", user, 1, -1, domain.ErrQuantityLimit},
		{"quantity above the cap", user, 1, domain.MaxCartQuantity + 1, domain.ErrQuantityLimit},
		{"unknown variant", user, 99, 1, domain.ErrNotFound},
		{"variant id zero", user, 0, 1, domain.ErrNotFound},
		{"invalid user", 0, 1, 1, domain.ErrInvalidUser},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			svc, store, _ := newTestService(t)

			_, err := svc.AddToCart(context.Background(), tt.userID, tt.variantID, tt.quantity)

			if !errors.Is(err, tt.wantErr) {
				t.Errorf("AddToCart() error = %v, want errors.Is(_, %v)", err, tt.wantErr)
			}
			if len(store.qty) != 0 {
				t.Errorf("store was modified: %v", store.qty)
			}
		})
	}
}

func TestAddToCartCatalogFailure(t *testing.T) {
	svc, store, catalog := newTestService(t)
	boom := errors.New("catalog down")
	catalog.err = boom

	_, err := svc.AddToCart(context.Background(), user, 1, 1)

	if !errors.Is(err, boom) {
		t.Errorf("AddToCart() error = %v, want it to wrap the catalog error", err)
	}
	if len(store.qty) != 0 {
		t.Errorf("store was modified: %v", store.qty)
	}
}

func TestSetQuantity(t *testing.T) {
	svc, store, _ := newTestService(t)
	ctx := context.Background()

	if err := svc.SetQuantity(ctx, user, 1, 2); !errors.Is(err, domain.ErrNotFound) {
		t.Errorf("SetQuantity() on a missing line error = %v, want ErrNotFound", err)
	}
	if _, err := svc.AddToCart(ctx, user, 1, 1); err != nil {
		t.Fatal(err)
	}
	if err := svc.SetQuantity(ctx, user, 1, 5); err != nil {
		t.Fatalf("SetQuantity() error = %v", err)
	}
	if got := store.qty[cartKey{user, 1}]; got != 5 {
		t.Errorf("quantity = %d, want 5", got)
	}
	for _, bad := range []int32{0, domain.MaxCartQuantity + 1} {
		if err := svc.SetQuantity(ctx, user, 1, bad); !errors.Is(err, domain.ErrQuantityLimit) {
			t.Errorf("SetQuantity(%d) error = %v, want ErrQuantityLimit", bad, err)
		}
	}
	if got := store.qty[cartKey{user, 1}]; got != 5 {
		t.Errorf("quantity changed by a rejected call: %d, want 5", got)
	}
}

func TestRemoveItem(t *testing.T) {
	svc, _, _ := newTestService(t)
	ctx := context.Background()

	if _, err := svc.AddToCart(ctx, user, 1, 1); err != nil {
		t.Fatal(err)
	}
	if err := svc.RemoveItem(ctx, user, 1); err != nil {
		t.Fatalf("RemoveItem() error = %v", err)
	}
	if err := svc.RemoveItem(ctx, user, 1); !errors.Is(err, domain.ErrNotFound) {
		t.Errorf("second RemoveItem() error = %v, want ErrNotFound", err)
	}
}

func TestCartsAreSeparatePerUser(t *testing.T) {
	svc, _, _ := newTestService(t)
	ctx := context.Background()

	if _, err := svc.AddToCart(ctx, user, 1, 2); err != nil {
		t.Fatal(err)
	}

	other, err := svc.GetCart(ctx, user+1)
	if err != nil {
		t.Fatalf("GetCart() error = %v", err)
	}
	if len(other.Lines) != 0 {
		t.Errorf("another user's cart has %d lines, want 0", len(other.Lines))
	}
	if err := svc.RemoveItem(ctx, user+1, 1); !errors.Is(err, domain.ErrNotFound) {
		t.Errorf("removing from another user's cart error = %v, want ErrNotFound", err)
	}
	if err := svc.SetQuantity(ctx, user+1, 1, 3); !errors.Is(err, domain.ErrNotFound) {
		t.Errorf("changing another user's cart error = %v, want ErrNotFound", err)
	}
}

func TestGetCartCalculatesTotalsFromCatalogPrices(t *testing.T) {
	svc, _, _ := newTestService(t)
	ctx := context.Background()

	if _, err := svc.AddToCart(ctx, user, 1, 2); err != nil {
		t.Fatal(err)
	}
	if _, err := svc.AddToCart(ctx, user, 2, 1); err != nil {
		t.Fatal(err)
	}

	cart, err := svc.GetCart(ctx, user)
	if err != nil {
		t.Fatalf("GetCart() error = %v", err)
	}

	if len(cart.Lines) != 2 {
		t.Fatalf("got %d lines, want 2", len(cart.Lines))
	}
	if cart.Subtotal != money(t, "3499.99") {
		t.Errorf("Subtotal = %s, want 3499.99", cart.Subtotal)
	}
	shirt := cart.Lines[0]
	if shirt.VariantID != 1 || shirt.ProductName != "Shirt" || shirt.Color != "Red" || shirt.Size != "M" {
		t.Errorf("first line = %+v, want the shirt", shirt)
	}
	if shirt.UnitPrice != money(t, "1500.00") || shirt.LineTotal != money(t, "3000.00") {
		t.Errorf("shirt prices = %s / %s, want 1500.00 / 3000.00", shirt.UnitPrice, shirt.LineTotal)
	}
	if shirt.SellerID != 3 || shirt.ImageURL != "https://img/shirt.jpg" {
		t.Errorf("shirt seller/image = %d / %q", shirt.SellerID, shirt.ImageURL)
	}
	if !shirt.InStock || !cart.Lines[1].InStock {
		t.Error("both lines should be in stock (2 of 10, and 1 of 1)")
	}
}

func TestGetCartMarksLinesWithTooLittleStock(t *testing.T) {
	svc, _, _ := newTestService(t)
	ctx := context.Background()

	// The cap has stock 1, the cart asks for 2.
	if _, err := svc.AddToCart(ctx, user, 2, 2); err != nil {
		t.Fatal(err)
	}

	cart, err := svc.GetCart(ctx, user)
	if err != nil {
		t.Fatalf("GetCart() error = %v", err)
	}
	if cart.Lines[0].InStock {
		t.Error("InStock = true, want false (2 requested, 1 available)")
	}
}

func TestGetCartEmptyIsAnEmptyListNotNil(t *testing.T) {
	svc, _, _ := newTestService(t)

	cart, err := svc.GetCart(context.Background(), user)
	if err != nil {
		t.Fatalf("GetCart() error = %v", err)
	}
	if cart.Lines == nil || len(cart.Lines) != 0 {
		t.Errorf("Lines = %#v, want an empty non-nil slice", cart.Lines)
	}
	if cart.Subtotal != 0 {
		t.Errorf("Subtotal = %s, want 0.00", cart.Subtotal)
	}
}

func TestGetCartDropsVariantsThatNoLongerExist(t *testing.T) {
	svc, store, catalog := newTestService(t)
	ctx := context.Background()

	if _, err := svc.AddToCart(ctx, user, 1, 1); err != nil {
		t.Fatal(err)
	}
	if _, err := svc.AddToCart(ctx, user, 2, 1); err != nil {
		t.Fatal(err)
	}
	delete(catalog.variants, 1) // the shirt is deleted from the catalog

	cart, err := svc.GetCart(ctx, user)
	if err != nil {
		t.Fatalf("GetCart() error = %v", err)
	}

	if len(cart.Lines) != 1 || cart.Lines[0].VariantID != 2 {
		t.Errorf("lines = %+v, want only the cap", cart.Lines)
	}
	if cart.Subtotal != money(t, "499.99") {
		t.Errorf("Subtotal = %s, want 499.99", cart.Subtotal)
	}
	if _, stillThere := store.qty[cartKey{user, 1}]; stillThere {
		t.Error("the stale line was not removed from the store")
	}
}

func TestGetCartCatalogFailure(t *testing.T) {
	svc, _, catalog := newTestService(t)
	if _, err := svc.AddToCart(context.Background(), user, 1, 1); err != nil {
		t.Fatal(err)
	}
	boom := errors.New("catalog down")
	catalog.err = boom

	if _, err := svc.GetCart(context.Background(), user); !errors.Is(err, boom) {
		t.Errorf("GetCart() error = %v, want it to wrap the catalog error", err)
	}
}
