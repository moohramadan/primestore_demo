package httpapi

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"sort"
	"strings"
	"testing"

	"github.com/gin-gonic/gin"

	"primestore_demo_backend/internal/orders"
	"primestore_demo_backend/internal/orders/domain"
	"primestore_demo_backend/internal/orders/service"
)

// ---- small in-memory fakes (the service tests have fuller ones) ------------

type fakeStore struct{ qty map[[2]int32]int32 }

func (f *fakeStore) UpsertCartItem(_ context.Context, userID, variantID, quantity, maxQuantity int32) (int32, error) {
	k := [2]int32{userID, variantID}
	n := f.qty[k] + quantity
	if n > maxQuantity {
		n = maxQuantity
	}
	f.qty[k] = n
	return n, nil
}

func (f *fakeStore) SetCartItemQuantity(_ context.Context, userID, variantID, quantity int32) (bool, error) {
	k := [2]int32{userID, variantID}
	if _, ok := f.qty[k]; !ok {
		return false, nil
	}
	f.qty[k] = quantity
	return true, nil
}

func (f *fakeStore) RemoveCartItem(_ context.Context, userID, variantID int32) (bool, error) {
	k := [2]int32{userID, variantID}
	if _, ok := f.qty[k]; !ok {
		return false, nil
	}
	delete(f.qty, k)
	return true, nil
}

func (f *fakeStore) ListCartItems(_ context.Context, userID int32) ([]domain.CartEntry, error) {
	var out []domain.CartEntry
	for k, q := range f.qty {
		if k[0] == userID {
			out = append(out, domain.CartEntry{VariantID: k[1], Quantity: q})
		}
	}
	sort.Slice(out, func(i, j int) bool { return out[i].VariantID < out[j].VariantID })
	return out, nil
}

func (f *fakeStore) ClearCart(context.Context, int32) error { return nil }

type fakeCatalog struct{}

func (fakeCatalog) GetVariants(_ context.Context, ids []int32) (map[int32]orders.VariantInfo, error) {
	all := map[int32]orders.VariantInfo{
		1: {VariantID: 1, ProductID: 10, ProductName: "Shirt", Color: "Red", Size: "M", UnitPrice: 150000, Stock: 10},
		2: {VariantID: 2, ProductID: 20, ProductName: "Cap", UnitPrice: 49999, Stock: 1},
	}
	out := map[int32]orders.VariantInfo{}
	for _, id := range ids {
		if v, ok := all[id]; ok {
			out[id] = v
		}
	}
	return out, nil
}

// ---- helpers ---------------------------------------------------------------

func newRouter() *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	svc := service.New(&fakeStore{qty: map[[2]int32]int32{}}, fakeCatalog{})
	Register(r, svc, func(*gin.Context) int32 { return 7 })
	return r
}

func do(r http.Handler, method, path, body string) *httptest.ResponseRecorder {
	req := httptest.NewRequest(method, path, strings.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	return w
}

func expectStatus(t *testing.T, w *httptest.ResponseRecorder, want int) {
	t.Helper()
	if w.Code != want {
		t.Fatalf("status = %d, want %d (body: %s)", w.Code, want, w.Body.String())
	}
}

// ---- tests -----------------------------------------------------------------

func TestAddCartItem(t *testing.T) {
	r := newRouter()

	w := do(r, http.MethodPost, "/cart/items", `{"variant_id":1,"quantity":2}`)
	expectStatus(t, w, http.StatusOK)

	var body struct {
		Message  string `json:"message"`
		Quantity int32  `json:"quantity"`
	}
	if err := json.Unmarshal(w.Body.Bytes(), &body); err != nil {
		t.Fatalf("response is not JSON: %v", err)
	}
	if body.Quantity != 2 || body.Message == "" {
		t.Errorf("body = %+v, want quantity 2 and a message", body)
	}

	// Adding again accumulates, and the response reports the resulting quantity.
	w = do(r, http.MethodPost, "/cart/items", `{"variant_id":1,"quantity":9}`)
	expectStatus(t, w, http.StatusOK)
	if err := json.Unmarshal(w.Body.Bytes(), &body); err != nil || body.Quantity != domain.MaxCartQuantity {
		t.Errorf("quantity after 2+9 = %d (err %v), want the cap %d", body.Quantity, err, domain.MaxCartQuantity)
	}
}

func TestAddCartItemErrors(t *testing.T) {
	tests := []struct {
		name string
		body string
		want int
	}{
		{"unknown variant", `{"variant_id":99,"quantity":1}`, http.StatusNotFound},
		{"quantity zero", `{"variant_id":1,"quantity":0}`, http.StatusBadRequest},
		{"quantity above the cap", `{"variant_id":1,"quantity":11}`, http.StatusBadRequest},
		{"negative quantity", `{"variant_id":1,"quantity":-2}`, http.StatusBadRequest},
		{"missing variant id", `{"quantity":1}`, http.StatusBadRequest},
		{"malformed JSON", `{"variant_id":`, http.StatusBadRequest},
		{"empty body", ``, http.StatusBadRequest},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			w := do(newRouter(), http.MethodPost, "/cart/items", tt.body)
			expectStatus(t, w, tt.want)
		})
	}
}

func TestGetCartEmptyIsAnEmptyJSONList(t *testing.T) {
	w := do(newRouter(), http.MethodGet, "/cart", "")
	expectStatus(t, w, http.StatusOK)

	body := w.Body.String()
	if !strings.Contains(body, `"items":[]`) {
		t.Errorf("body = %s, want an empty list (not null) for items", body)
	}
	if !strings.Contains(body, `"subtotal":"0.00"`) {
		t.Errorf("body = %s, want subtotal 0.00", body)
	}
}

func TestGetCartResponseShape(t *testing.T) {
	r := newRouter()
	expectStatus(t, do(r, http.MethodPost, "/cart/items", `{"variant_id":1,"quantity":2}`), http.StatusOK)
	expectStatus(t, do(r, http.MethodPost, "/cart/items", `{"variant_id":2,"quantity":1}`), http.StatusOK)

	w := do(r, http.MethodGet, "/cart", "")
	expectStatus(t, w, http.StatusOK)

	var got cartResponse
	if err := json.Unmarshal(w.Body.Bytes(), &got); err != nil {
		t.Fatalf("response is not JSON: %v", err)
	}
	if got.Subtotal != "3499.99" {
		t.Errorf("subtotal = %q, want 3499.99", got.Subtotal)
	}
	if len(got.Items) != 2 {
		t.Fatalf("got %d items, want 2", len(got.Items))
	}
	shirt := got.Items[0]
	want := cartItemResponse{
		VariantID: 1, ProductID: 10, Name: "Shirt", Color: "Red", Size: "M",
		UnitPrice: "1500.00", Quantity: 2, LineTotal: "3000.00", InStock: true,
	}
	if shirt != want {
		t.Errorf("first item = %+v, want %+v", shirt, want)
	}
}

func TestSetCartItemQuantity(t *testing.T) {
	r := newRouter()

	expectStatus(t, do(r, http.MethodPut, "/cart/items/1", `{"quantity":3}`), http.StatusNotFound)

	expectStatus(t, do(r, http.MethodPost, "/cart/items", `{"variant_id":1,"quantity":1}`), http.StatusOK)
	expectStatus(t, do(r, http.MethodPut, "/cart/items/1", `{"quantity":3}`), http.StatusOK)
	expectStatus(t, do(r, http.MethodPut, "/cart/items/1", `{"quantity":0}`), http.StatusBadRequest)
	expectStatus(t, do(r, http.MethodPut, "/cart/items/1", `{"quantity":11}`), http.StatusBadRequest)
	expectStatus(t, do(r, http.MethodPut, "/cart/items/abc", `{"quantity":3}`), http.StatusBadRequest)
	expectStatus(t, do(r, http.MethodPut, "/cart/items/-1", `{"quantity":3}`), http.StatusBadRequest)
	expectStatus(t, do(r, http.MethodPut, "/cart/items/4294967297", `{"quantity":3}`), http.StatusBadRequest) // would wrap to 1 as int32
}

func TestRemoveCartItem(t *testing.T) {
	r := newRouter()
	expectStatus(t, do(r, http.MethodPost, "/cart/items", `{"variant_id":1,"quantity":1}`), http.StatusOK)

	expectStatus(t, do(r, http.MethodDelete, "/cart/items/1", ""), http.StatusOK)
	expectStatus(t, do(r, http.MethodDelete, "/cart/items/1", ""), http.StatusNotFound)
	expectStatus(t, do(r, http.MethodDelete, "/cart/items/abc", ""), http.StatusBadRequest)
}
