package domain

import (
	"errors"
	"testing"
)

const testUserID int32 = 42

func mustParseMoney(t *testing.T, input string) Money {
	t.Helper()
	money, err := ParseMoney(input)
	if err != nil {
		t.Fatalf("ParseMoney(%q) error = %v", input, err)
	}
	return money
}

func TestNewOrderCalculatesTotalsAndDefaults(t *testing.T) {
	items := []OrderItem{
		{VariantID: 1, ProductID: 1, ProductName: "First", UnitPrice: mustParseMoney(t, "1500.00"), Quantity: 2},
		{VariantID: 2, ProductID: 2, ProductName: "Second", UnitPrice: mustParseMoney(t, "499.99"), Quantity: 1},
	}
	address := AddressSnapshot{
		FullName: "Ada Lovelace",
		Line1:    "1 Example Street",
		City:     "London",
		Country:  "UK",
	}

	got, err := NewOrder(testUserID, items, mustParseMoney(t, "500.00"), address)
	if err != nil {
		t.Fatalf("NewOrder() error = %v", err)
	}

	if got.UserID != testUserID {
		t.Errorf("UserID = %d, want %d", got.UserID, testUserID)
	}
	if got.Subtotal != mustParseMoney(t, "3499.99") {
		t.Errorf("Subtotal = %s, want 3499.99", got.Subtotal)
	}
	if got.DeliveryFee != mustParseMoney(t, "500.00") {
		t.Errorf("DeliveryFee = %s, want 500.00", got.DeliveryFee)
	}
	if got.Total != mustParseMoney(t, "3999.99") {
		t.Errorf("Total = %s, want 3999.99", got.Total)
	}
	if got.Items[0].LineTotal != mustParseMoney(t, "3000.00") {
		t.Errorf("first LineTotal = %s, want 3000.00", got.Items[0].LineTotal)
	}
	if got.Items[1].LineTotal != mustParseMoney(t, "499.99") {
		t.Errorf("second LineTotal = %s, want 499.99", got.Items[1].LineTotal)
	}
	if got.Status != StatusPlaced {
		t.Errorf("Status = %q, want %q", got.Status, StatusPlaced)
	}
	if got.PaymentStatus != PaymentUnpaid {
		t.Errorf("PaymentStatus = %q, want %q", got.PaymentStatus, PaymentUnpaid)
	}
	if got.Address != address {
		t.Errorf("Address = %+v, want %+v", got.Address, address)
	}
}

func TestNewOrderIgnoresCallerLineTotalAndDoesNotMutateInput(t *testing.T) {
	items := []OrderItem{
		{VariantID: 1, UnitPrice: mustParseMoney(t, "10.00"), Quantity: 3, LineTotal: 1}, // wrong on purpose
	}

	got, err := NewOrder(testUserID, items, 0, AddressSnapshot{})
	if err != nil {
		t.Fatalf("NewOrder() error = %v", err)
	}

	if got.Items[0].LineTotal != mustParseMoney(t, "30.00") {
		t.Errorf("LineTotal = %s, want 30.00 (caller's value must be ignored)", got.Items[0].LineTotal)
	}
	if items[0].LineTotal != 1 {
		t.Errorf("NewOrder mutated the caller's slice: LineTotal = %s", items[0].LineTotal)
	}
}

func TestNewOrderRejectsInvalidUser(t *testing.T) {
	items := []OrderItem{{VariantID: 1, UnitPrice: 100, Quantity: 1}}

	for _, userID := range []int32{0, -1} {
		_, err := NewOrder(userID, items, 0, AddressSnapshot{})
		if !errors.Is(err, ErrInvalidUser) {
			t.Errorf("NewOrder(userID=%d) error = %v, want %v", userID, err, ErrInvalidUser)
		}
	}
}

func TestNewOrderValidationErrors(t *testing.T) {
	tests := []struct {
		name    string
		items   []OrderItem
		fee     Money
		wantErr error
	}{
		{
			name:    "empty items",
			fee:     mustParseMoney(t, "500.00"),
			wantErr: ErrEmptyCart,
		},
		{
			name:    "zero quantity",
			items:   []OrderItem{{VariantID: 1, UnitPrice: mustParseMoney(t, "1.00"), Quantity: 0}},
			wantErr: ErrQuantityLimit,
		},
		{
			name:    "negative quantity",
			items:   []OrderItem{{VariantID: 1, UnitPrice: mustParseMoney(t, "1.00"), Quantity: -1}},
			wantErr: ErrQuantityLimit,
		},
		{
			name:    "negative delivery fee",
			items:   []OrderItem{{VariantID: 1, UnitPrice: mustParseMoney(t, "1.00"), Quantity: 1}},
			fee:     -1,
			wantErr: ErrInvalidAmount,
		},
		{
			name:    "delivery fee above database limit",
			items:   []OrderItem{{VariantID: 1, UnitPrice: mustParseMoney(t, "1.00"), Quantity: 1}},
			fee:     maxTotal + 1,
			wantErr: ErrInvalidAmount,
		},
		{
			name:    "negative unit price",
			items:   []OrderItem{{VariantID: 1, UnitPrice: -1, Quantity: 1}},
			wantErr: ErrInvalidAmount,
		},
		{
			name:    "unit price above database limit",
			items:   []OrderItem{{VariantID: 1, UnitPrice: maxUnitPrice + 1, Quantity: 1}},
			wantErr: ErrInvalidAmount,
		},
		{
			name: "duplicate variant",
			items: []OrderItem{
				{VariantID: 1, UnitPrice: mustParseMoney(t, "1.00"), Quantity: 1},
				{VariantID: 1, UnitPrice: mustParseMoney(t, "2.00"), Quantity: 1},
			},
			wantErr: ErrDuplicateVariant,
		},
		{
			name:    "line total above database limit",
			items:   []OrderItem{{VariantID: 1, UnitPrice: maxUnitPrice, Quantity: 10001}},
			wantErr: ErrInvalidAmount,
		},
		{
			name: "subtotal above database limit",
			items: []OrderItem{
				{VariantID: 1, UnitPrice: maxUnitPrice, Quantity: 6000},
				{VariantID: 2, UnitPrice: maxUnitPrice, Quantity: 6000},
			},
			wantErr: ErrInvalidAmount,
		},
		{
			name:    "total above database limit",
			items:   []OrderItem{{VariantID: 1, UnitPrice: 1, Quantity: 1}},
			fee:     maxTotal,
			wantErr: ErrInvalidAmount,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := NewOrder(testUserID, tt.items, tt.fee, AddressSnapshot{})
			if !errors.Is(err, tt.wantErr) {
				t.Errorf("NewOrder() error = %v, want errors.Is(_, %v)", err, tt.wantErr)
			}
		})
	}
}

// These cases sit exactly ON the limits and must succeed. They catch a ">"
// accidentally turned into ">=" in NewOrder.
func TestNewOrderAcceptsValuesAtTheLimits(t *testing.T) {
	tests := []struct {
		name      string
		items     []OrderItem
		fee       Money
		wantTotal Money
	}{
		{
			name:      "unit price exactly at limit",
			items:     []OrderItem{{VariantID: 1, UnitPrice: maxUnitPrice, Quantity: 1}},
			wantTotal: maxUnitPrice,
		},
		{
			name:      "line total just under limit",
			items:     []OrderItem{{VariantID: 1, UnitPrice: maxUnitPrice, Quantity: 10000}},
			wantTotal: maxUnitPrice * 10000,
		},
		{
			name:      "total exactly at limit",
			items:     []OrderItem{{VariantID: 1, UnitPrice: 1, Quantity: 1}},
			fee:       maxTotal - 1,
			wantTotal: maxTotal,
		},
		{
			name:      "free item is allowed in the domain",
			items:     []OrderItem{{VariantID: 1, UnitPrice: 0, Quantity: 1}},
			wantTotal: 0,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := NewOrder(testUserID, tt.items, tt.fee, AddressSnapshot{})
			if err != nil {
				t.Fatalf("NewOrder() error = %v", err)
			}
			if got.Total != tt.wantTotal {
				t.Errorf("Total = %d, want %d", got.Total, tt.wantTotal)
			}
		})
	}
}

func TestOrderTransition(t *testing.T) {
	tests := []struct {
		name    string
		from    Status
		to      Status
		wantErr bool
	}{
		{"placed to cancelled", StatusPlaced, StatusCancelled, false},
		{"placed to fulfilled", StatusPlaced, StatusFulfilled, false},
		{"placed to placed", StatusPlaced, StatusPlaced, true},
		{"fulfilled to cancelled", StatusFulfilled, StatusCancelled, true},
		{"cancelled to placed", StatusCancelled, StatusPlaced, true},
		{"unknown source status", Status("shipped"), StatusFulfilled, true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			order := Order{Status: tt.from}

			err := order.Transition(tt.to)

			if tt.wantErr {
				if !errors.Is(err, ErrInvalidTransition) {
					t.Fatalf("Transition() error = %v, want %v", err, ErrInvalidTransition)
				}
				if order.Status != tt.from {
					t.Errorf("Status after rejected transition = %q, want %q (unchanged)", order.Status, tt.from)
				}
				return
			}

			if err != nil {
				t.Fatalf("Transition() error = %v", err)
			}
			if order.Status != tt.to {
				t.Errorf("Status = %q, want %q", order.Status, tt.to)
			}
		})
	}
}
