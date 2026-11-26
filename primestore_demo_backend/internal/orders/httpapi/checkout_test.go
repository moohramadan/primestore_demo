package httpapi

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/gin-gonic/gin"

	"primestore_demo_backend/internal/orders"
	"primestore_demo_backend/internal/orders/domain"
	"primestore_demo_backend/internal/orders/service"
)

// ---- fakes -----------------------------------------------------------------

type fakeOrderStore struct {
	byKey map[string]domain.Order
	next  int64
}

func (f *fakeOrderStore) FindOrderByIdempotencyKey(_ context.Context, _ int32, key string) (domain.Order, error) {
	if o, ok := f.byKey[key]; ok {
		return o, nil
	}
	return domain.Order{}, domain.ErrNotFound
}

func (f *fakeOrderStore) CreateOrder(_ context.Context, o domain.Order, key string) (domain.Order, error) {
	f.next++
	o.ID = f.next
	o.CreatedAt = time.Date(2026, 11, 17, 10, 0, 0, 0, time.UTC)
	f.byKey[key] = o
	return o, nil
}

type fakeInventory struct{ reserveErr error }

func (f *fakeInventory) Reserve(context.Context, string, []orders.ReserveItem) error {
	return f.reserveErr
}
func (f *fakeInventory) Commit(context.Context, string) error  { return nil }
func (f *fakeInventory) Release(context.Context, string) error { return nil }

type fakeAddresses struct{}

func (fakeAddresses) Get(_ context.Context, userID int32, addressID int64) (orders.Address, error) {
	if userID == 7 && addressID == 5 {
		return orders.Address{FullName: "Ada Lovelace", Line1: "1 Example Street", City: "Exampleville", Country: "Examplia"}, nil
	}
	return orders.Address{}, domain.ErrNotFound
}

// ---- helpers ---------------------------------------------------------------

const goodKey = "key-12345678"

func newCheckoutRouter(inv *fakeInventory) *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()

	userID := func(*gin.Context) int32 { return 7 }
	cart := &fakeStore{qty: map[[2]int32]int32{}}

	Register(r, service.New(cart, fakeCatalog{}), userID) // cart routes, to fill the cart
	checkout := service.NewCheckoutService(service.CheckoutDeps{
		Cart:      cart,
		Orders:    &fakeOrderStore{byKey: map[string]domain.Order{}},
		Catalog:   fakeCatalog{},
		Inventory: inv,
		Addresses: fakeAddresses{},
	}, service.CheckoutConfig{})
	RegisterCheckout(r, checkout, userID)
	return r
}

func postCheckout(r http.Handler, body, key string) *httptest.ResponseRecorder {
	req := httptest.NewRequest(http.MethodPost, "/checkout", strings.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	if key != "" {
		req.Header.Set(idempotencyHeader, key)
	}
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	return w
}

func fillCart(t *testing.T, r http.Handler) {
	t.Helper()
	expectStatus(t, do(r, http.MethodPost, "/cart/items", `{"variant_id":1,"quantity":2}`), http.StatusOK)
}

// ---- tests -----------------------------------------------------------------

func TestCheckoutCreatesAnOrder(t *testing.T) {
	r := newCheckoutRouter(&fakeInventory{})
	fillCart(t, r)

	w := postCheckout(r, `{"address_id":5}`, goodKey)
	expectStatus(t, w, http.StatusCreated)

	var got orderResponse
	if err := json.Unmarshal(w.Body.Bytes(), &got); err != nil {
		t.Fatalf("response is not JSON: %v", err)
	}
	if got.ID != 1 || got.Status != "placed" || got.PaymentStatus != "unpaid" {
		t.Errorf("order = %+v", got)
	}
	if !strings.HasPrefix(got.OrderNumber, "PS-") {
		t.Errorf("order number = %q, want the PS- prefix", got.OrderNumber)
	}
	if got.Subtotal != "3000.00" || got.DeliveryFee != "0.00" || got.Total != "3000.00" {
		t.Errorf("amounts = %s / %s / %s, want 3000.00 / 0.00 / 3000.00", got.Subtotal, got.DeliveryFee, got.Total)
	}
	if len(got.Items) != 1 || got.Items[0].Name != "Shirt" || got.Items[0].VariantLabel != "Red / M" ||
		got.Items[0].UnitPrice != "1500.00" || got.Items[0].Quantity != 2 || got.Items[0].LineTotal != "3000.00" {
		t.Errorf("items = %+v", got.Items)
	}
	if got.Address.FullName != "Ada Lovelace" || got.Address.AddressLine1 != "1 Example Street" {
		t.Errorf("address = %+v", got.Address)
	}
}

func TestCheckoutReplayReturns200AndTheSameOrder(t *testing.T) {
	r := newCheckoutRouter(&fakeInventory{})
	fillCart(t, r)

	first := postCheckout(r, `{"address_id":5}`, goodKey)
	expectStatus(t, first, http.StatusCreated)
	second := postCheckout(r, `{"address_id":5}`, goodKey)
	expectStatus(t, second, http.StatusOK)

	var a, b orderResponse
	if err := json.Unmarshal(first.Body.Bytes(), &a); err != nil {
		t.Fatal(err)
	}
	if err := json.Unmarshal(second.Body.Bytes(), &b); err != nil {
		t.Fatal(err)
	}
	if a.ID != b.ID || a.OrderNumber != b.OrderNumber {
		t.Errorf("replay returned %s, want the original %s", b.OrderNumber, a.OrderNumber)
	}
}

func TestCheckoutErrors(t *testing.T) {
	tests := []struct {
		name     string
		inv      *fakeInventory
		fill     bool
		body     string
		key      string
		want     int
		wantText string
	}{
		{"missing idempotency key", &fakeInventory{}, true, `{"address_id":5}`, "", http.StatusBadRequest, "Idempotency-Key"},
		{"bad idempotency key", &fakeInventory{}, true, `{"address_id":5}`, "short", http.StatusBadRequest, "Idempotency-Key"},
		{"missing address id", &fakeInventory{}, true, `{}`, goodKey, http.StatusBadRequest, ""},
		{"malformed JSON", &fakeInventory{}, true, `{"address_id":`, goodKey, http.StatusBadRequest, ""},
		{"empty cart", &fakeInventory{}, false, `{"address_id":5}`, goodKey, http.StatusBadRequest, "cart is empty"},
		{"unknown address", &fakeInventory{}, true, `{"address_id":6}`, goodKey, http.StatusNotFound, "address not found"},
		{"out of stock", &fakeInventory{reserveErr: &domain.OutOfStockError{VariantID: 1}}, true,
			`{"address_id":5}`, goodKey, http.StatusConflict, `"variant_id":1`},
		{"reservation expired", &fakeInventory{reserveErr: domain.ErrReservationExpired}, true,
			`{"address_id":5}`, goodKey, http.StatusConflict, "try again"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			r := newCheckoutRouter(tt.inv)
			if tt.fill {
				fillCart(t, r)
			}

			w := postCheckout(r, tt.body, tt.key)

			expectStatus(t, w, tt.want)
			if tt.wantText != "" && !strings.Contains(w.Body.String(), tt.wantText) {
				t.Errorf("body = %s, want it to contain %q", w.Body.String(), tt.wantText)
			}
		})
	}
}

func TestRegisterCheckoutRunsExtraMiddlewareFirst(t *testing.T) {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	svc := service.NewCheckoutService(service.CheckoutDeps{
		Cart:      &fakeStore{qty: map[[2]int32]int32{}},
		Orders:    &fakeOrderStore{byKey: map[string]domain.Order{}},
		Catalog:   fakeCatalog{},
		Inventory: &fakeInventory{},
		Addresses: fakeAddresses{},
	}, service.CheckoutConfig{})

	blocker := func(c *gin.Context) {
		c.AbortWithStatusJSON(http.StatusTooManyRequests, gin.H{"error": "slow down"})
	}
	RegisterCheckout(r, svc, func(*gin.Context) int32 { return 7 }, blocker)

	w := postCheckout(r, `{"address_id":5}`, goodKey)

	expectStatus(t, w, http.StatusTooManyRequests)
}
