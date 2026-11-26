package domain

import (
	"encoding/json"
	"fmt"
	"time"
)

// EventOrderPlaced is the outbox event type written when an order is created.
const EventOrderPlaced = "order.placed"

// The payload is a contract with every future consumer (notifications, seller
// earnings, analytics). Add fields freely, but never rename or remove one
// without bumping Version.
type orderPlacedItem struct {
	VariantID int32  `json:"variant_id"`
	ProductID int32  `json:"product_id"`
	SellerID  int32  `json:"seller_id"`
	Name      string `json:"name"`
	Quantity  int32  `json:"quantity"`
	UnitPrice string `json:"unit_price"`
	LineTotal string `json:"line_total"`
}

type orderPlacedPayload struct {
	Version     int               `json:"version"`
	OrderID     int64             `json:"order_id"`
	OrderNumber string            `json:"order_number"`
	UserID      int32             `json:"user_id"`
	Subtotal    string            `json:"subtotal"`
	DeliveryFee string            `json:"delivery_fee"`
	Total       string            `json:"total"`
	PlacedAt    time.Time         `json:"placed_at"`
	Items       []orderPlacedItem `json:"items"`
}

// OrderPlacedPayload builds the JSON payload of the order.placed event. The
// order must already be saved (it needs its id).
func OrderPlacedPayload(o Order) ([]byte, error) {
	if o.ID < 1 {
		return nil, fmt.Errorf("order placed event: order has no id yet")
	}

	items := make([]orderPlacedItem, len(o.Items))
	for i, it := range o.Items {
		items[i] = orderPlacedItem{
			VariantID: it.VariantID,
			ProductID: it.ProductID,
			SellerID:  it.SellerID,
			Name:      it.ProductName,
			Quantity:  it.Quantity,
			UnitPrice: it.UnitPrice.String(),
			LineTotal: it.LineTotal.String(),
		}
	}

	return json.Marshal(orderPlacedPayload{
		Version:     1,
		OrderID:     o.ID,
		OrderNumber: o.OrderNumber,
		UserID:      o.UserID,
		Subtotal:    o.Subtotal.String(),
		DeliveryFee: o.DeliveryFee.String(),
		Total:       o.Total.String(),
		PlacedAt:    o.CreatedAt.UTC(),
		Items:       items,
	})
}
