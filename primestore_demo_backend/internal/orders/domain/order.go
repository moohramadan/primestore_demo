package domain

import (
	"fmt"
	"time"
)

// These limits must match the column precision in migration 000015:
// order_items.unit_price is NUMERIC(10,2) and totals are NUMERIC(14,2).
// Both are expressed in cents.
const (
	maxUnitPrice Money = 9_999_999_999
	maxTotal     Money = 99_999_999_999_999
)

// PaymentStatus is the payment state of an order. The values must match the
// CHECK constraint on orders.payment_status.
type PaymentStatus string

const (
	PaymentUnpaid   PaymentStatus = "unpaid"
	PaymentPaid     PaymentStatus = "paid"
	PaymentRefunded PaymentStatus = "refunded"
)

// AddressSnapshot stores the delivery address as it was when the order was
// placed, so later address changes do not alter the order.
type AddressSnapshot struct {
	FullName   string
	Phone      string
	Line1      string
	Line2      string
	City       string
	State      string
	PostalCode string
	Country    string
}

// Order is a placed order and its immutable item and address snapshots.
type Order struct {
	ID            int64  // Assigned by the store after insertion.
	OrderNumber   string // Human-readable, unique. Assigned by the checkout service.
	UserID        int32
	Status        Status
	PaymentStatus PaymentStatus
	StockRef      string // The inventory reservation that holds this order's stock.
	Address       AddressSnapshot
	Subtotal      Money
	DeliveryFee   Money
	Total         Money
	CreatedAt     time.Time // Assigned by the store after insertion.
	Items         []OrderItem
}

// OrderItem stores the product details and price captured when the order was
// placed.
type OrderItem struct {
	VariantID    int32
	ProductID    int32
	SellerID     int32
	ProductName  string
	VariantLabel string
	ImageURL     string
	UnitPrice    Money
	Quantity     int32
	LineTotal    Money
}

// NewOrder builds an order owned by userID, with calculated line totals and
// order totals. It never trusts a LineTotal supplied by the caller and never
// modifies the items slice it is given.
//
// A unit price of zero is allowed here (the database allows it). Whether a free
// item makes sense is a business rule for the service layer.
func NewOrder(userID int32, items []OrderItem, deliveryFee Money, address AddressSnapshot) (Order, error) {
	if userID < 1 {
		return Order{}, fmt.Errorf("user id %d: %w", userID, ErrInvalidUser)
	}
	if len(items) == 0 {
		return Order{}, ErrEmptyCart
	}
	if deliveryFee < 0 {
		return Order{}, fmt.Errorf("delivery fee: %w", ErrInvalidAmount)
	}
	if deliveryFee > maxTotal {
		return Order{}, fmt.Errorf("delivery fee exceeds maximum: %w", ErrInvalidAmount)
	}

	order := Order{
		UserID:        userID,
		Status:        StatusPlaced,
		PaymentStatus: PaymentUnpaid,
		Address:       address,
		DeliveryFee:   deliveryFee,
		Items:         make([]OrderItem, len(items)),
	}
	seenVariants := make(map[int32]bool, len(items))

	for i, item := range items {
		if item.Quantity < 1 {
			return Order{}, fmt.Errorf("item %d: %w", i, ErrQuantityLimit)
		}
		if item.UnitPrice < 0 {
			return Order{}, fmt.Errorf("item %d unit price: %w", i, ErrInvalidAmount)
		}
		if item.UnitPrice > maxUnitPrice {
			return Order{}, fmt.Errorf("item %d unit price exceeds maximum: %w", i, ErrInvalidAmount)
		}
		if seenVariants[item.VariantID] {
			return Order{}, fmt.Errorf("item %d variant %d: %w", i, item.VariantID, ErrDuplicateVariant)
		}
		seenVariants[item.VariantID] = true
		if item.UnitPrice > maxTotal/Money(item.Quantity) {
			return Order{}, fmt.Errorf("item %d line total exceeds maximum: %w", i, ErrInvalidAmount)
		}

		item.LineTotal = item.UnitPrice.Mul(item.Quantity)
		if order.Subtotal > maxTotal-item.LineTotal {
			return Order{}, fmt.Errorf("order subtotal exceeds maximum: %w", ErrInvalidAmount)
		}
		order.Subtotal = order.Subtotal.Add(item.LineTotal)
		order.Items[i] = item
	}

	if order.Subtotal > maxTotal-deliveryFee {
		return Order{}, fmt.Errorf("order total exceeds maximum: %w", ErrInvalidAmount)
	}
	order.Total = order.Subtotal.Add(deliveryFee)

	return order, nil
}

// Transition changes the order status if the state machine allows the move.
// On error the order is left unchanged.
func (o *Order) Transition(to Status) error {
	if !o.Status.CanTransitionTo(to) {
		return fmt.Errorf("%s -> %s: %w", o.Status, to, ErrInvalidTransition)
	}
	o.Status = to
	return nil
}
