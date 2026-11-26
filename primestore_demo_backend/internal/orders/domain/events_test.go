package domain

import (
	"encoding/json"
	"testing"
	"time"
)

func TestOrderPlacedPayload(t *testing.T) {
	order, err := NewOrder(42, []OrderItem{
		{VariantID: 1, ProductID: 10, SellerID: 3, ProductName: "Shirt", UnitPrice: mustParseMoney(t, "1500.00"), Quantity: 2},
		{VariantID: 2, ProductID: 20, ProductName: "Cap", UnitPrice: mustParseMoney(t, "499.99"), Quantity: 1},
	}, mustParseMoney(t, "500.00"), AddressSnapshot{})
	if err != nil {
		t.Fatalf("NewOrder() error = %v", err)
	}
	order.ID = 7
	order.OrderNumber = "PS-20261117-ABCDEF"
	order.CreatedAt = time.Date(2026, 11, 17, 10, 30, 0, 0, time.UTC)

	raw, err := OrderPlacedPayload(order)
	if err != nil {
		t.Fatalf("OrderPlacedPayload() error = %v", err)
	}

	var got struct {
		Version     int    `json:"version"`
		OrderID     int64  `json:"order_id"`
		OrderNumber string `json:"order_number"`
		UserID      int32  `json:"user_id"`
		Subtotal    string `json:"subtotal"`
		DeliveryFee string `json:"delivery_fee"`
		Total       string `json:"total"`
		PlacedAt    string `json:"placed_at"`
		Items       []struct {
			VariantID int32  `json:"variant_id"`
			SellerID  int32  `json:"seller_id"`
			Name      string `json:"name"`
			Quantity  int32  `json:"quantity"`
			UnitPrice string `json:"unit_price"`
			LineTotal string `json:"line_total"`
		} `json:"items"`
	}
	if err := json.Unmarshal(raw, &got); err != nil {
		t.Fatalf("payload is not valid JSON: %v", err)
	}

	if got.Version != 1 {
		t.Errorf("version = %d, want 1", got.Version)
	}
	if got.OrderID != 7 || got.OrderNumber != "PS-20261117-ABCDEF" || got.UserID != 42 {
		t.Errorf("identity fields = %d / %s / %d", got.OrderID, got.OrderNumber, got.UserID)
	}
	if got.Subtotal != "3499.99" || got.DeliveryFee != "500.00" || got.Total != "3999.99" {
		t.Errorf("amounts = %s / %s / %s, want 3499.99 / 500.00 / 3999.99", got.Subtotal, got.DeliveryFee, got.Total)
	}
	if got.PlacedAt != "2026-11-17T10:30:00Z" {
		t.Errorf("placed_at = %s, want 2026-11-17T10:30:00Z", got.PlacedAt)
	}
	if len(got.Items) != 2 {
		t.Fatalf("got %d items, want 2", len(got.Items))
	}
	if first := got.Items[0]; first.VariantID != 1 || first.SellerID != 3 || first.Name != "Shirt" ||
		first.Quantity != 2 || first.UnitPrice != "1500.00" || first.LineTotal != "3000.00" {
		t.Errorf("first item = %+v", first)
	}
}

func TestOrderPlacedPayloadNeedsASavedOrder(t *testing.T) {
	if _, err := OrderPlacedPayload(Order{}); err == nil {
		t.Error("OrderPlacedPayload() on an order without an id should fail")
	}
}
