package domain

import (
	"errors"
	"testing"
)

func TestValidateCartQuantity(t *testing.T) {
	tests := []struct {
		name    string
		in      int32
		wantErr bool
	}{
		{"zero", 0, true},
		{"negative", -1, true},
		{"one", 1, false},
		{"at the maximum", MaxCartQuantity, false},
		{"above the maximum", MaxCartQuantity + 1, true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := ValidateCartQuantity(tt.in)
			if (err != nil) != tt.wantErr {
				t.Fatalf("ValidateCartQuantity(%d) error = %v, wantErr %t", tt.in, err, tt.wantErr)
			}
			if tt.wantErr && !errors.Is(err, ErrQuantityLimit) {
				t.Errorf("error = %v, want errors.Is(_, ErrQuantityLimit)", err)
			}
		})
	}
}

func TestBuildCartCalculatesTotals(t *testing.T) {
	lines := []CartLine{
		{VariantID: 1, UnitPrice: mustParseMoney(t, "1500.00"), Quantity: 2, LineTotal: 1}, // wrong on purpose
		{VariantID: 2, UnitPrice: mustParseMoney(t, "499.99"), Quantity: 1},
	}

	cart, err := BuildCart(lines)
	if err != nil {
		t.Fatalf("BuildCart() error = %v", err)
	}

	if cart.Lines[0].LineTotal != mustParseMoney(t, "3000.00") {
		t.Errorf("first LineTotal = %s, want 3000.00 (caller's value must be ignored)", cart.Lines[0].LineTotal)
	}
	if cart.Lines[1].LineTotal != mustParseMoney(t, "499.99") {
		t.Errorf("second LineTotal = %s, want 499.99", cart.Lines[1].LineTotal)
	}
	if cart.Subtotal != mustParseMoney(t, "3499.99") {
		t.Errorf("Subtotal = %s, want 3499.99", cart.Subtotal)
	}
	if lines[0].LineTotal != 1 {
		t.Errorf("BuildCart mutated the caller's slice: LineTotal = %s", lines[0].LineTotal)
	}
}

func TestBuildCartEmptyIsAnEmptyListNotNil(t *testing.T) {
	for _, in := range [][]CartLine{nil, {}} {
		cart, err := BuildCart(in)
		if err != nil {
			t.Fatalf("BuildCart() error = %v", err)
		}
		if cart.Lines == nil {
			t.Error("Lines is nil, want an empty non-nil slice (JSON must say [], not null)")
		}
		if len(cart.Lines) != 0 || cart.Subtotal != 0 {
			t.Errorf("empty cart = %+v, want no lines and subtotal 0", cart)
		}
	}
}

func TestBuildCartRejectsInvalidLines(t *testing.T) {
	tests := []struct {
		name    string
		lines   []CartLine
		wantErr error
	}{
		{"zero quantity", []CartLine{{VariantID: 1, UnitPrice: 100, Quantity: 0}}, ErrQuantityLimit},
		{"negative price", []CartLine{{VariantID: 1, UnitPrice: -1, Quantity: 1}}, ErrInvalidAmount},
		{"price above limit", []CartLine{{VariantID: 1, UnitPrice: maxUnitPrice + 1, Quantity: 1}}, ErrInvalidAmount},
		{"line total above limit", []CartLine{{VariantID: 1, UnitPrice: maxUnitPrice, Quantity: 10001}}, ErrInvalidAmount},
		{"subtotal above limit", []CartLine{
			{VariantID: 1, UnitPrice: maxUnitPrice, Quantity: 6000},
			{VariantID: 2, UnitPrice: maxUnitPrice, Quantity: 6000},
		}, ErrInvalidAmount},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := BuildCart(tt.lines)
			if !errors.Is(err, tt.wantErr) {
				t.Errorf("BuildCart() error = %v, want errors.Is(_, %v)", err, tt.wantErr)
			}
		})
	}
}
