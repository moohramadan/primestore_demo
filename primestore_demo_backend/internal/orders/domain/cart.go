package domain

import "fmt"

// MaxCartQuantity is the most units of one variant a cart line may hold. It must
// match the CHECK constraint on cart_items.quantity (migration 000014).
const MaxCartQuantity int32 = 10

// ValidateCartQuantity reports whether q is an allowed cart line quantity.
func ValidateCartQuantity(q int32) error {
	if q < 1 || q > MaxCartQuantity {
		return fmt.Errorf("quantity %d (allowed 1 to %d): %w", q, MaxCartQuantity, ErrQuantityLimit)
	}
	return nil
}

// CartEntry is what the store knows about a cart line: which variant, how many.
// Everything else (name, price, stock) comes from the catalog.
type CartEntry struct {
	VariantID int32
	Quantity  int32
}

// CartLine is a cart entry enriched with catalog data, ready to display.
type CartLine struct {
	VariantID   int32
	ProductID   int32
	SellerID    int32
	ProductName string
	Color       string
	Size        string
	ImageURL    string
	UnitPrice   Money
	Quantity    int32
	LineTotal   Money
	InStock     bool // the catalog holds at least Quantity units
}

// Cart is the buyer's cart with calculated totals.
type Cart struct {
	Lines    []CartLine
	Subtotal Money
}

// BuildCart calculates every line total and the subtotal. It ignores any
// LineTotal the caller filled in, never modifies the slice it is given, and
// always returns a non-nil Lines slice (an empty cart is an empty list, not null).
func BuildCart(lines []CartLine) (Cart, error) {
	cart := Cart{Lines: make([]CartLine, len(lines))}

	for i, line := range lines {
		if line.Quantity < 1 {
			return Cart{}, fmt.Errorf("line %d: %w", i, ErrQuantityLimit)
		}
		if line.UnitPrice < 0 || line.UnitPrice > maxUnitPrice {
			return Cart{}, fmt.Errorf("line %d unit price: %w", i, ErrInvalidAmount)
		}
		if line.UnitPrice > maxTotal/Money(line.Quantity) {
			return Cart{}, fmt.Errorf("line %d total exceeds maximum: %w", i, ErrInvalidAmount)
		}

		line.LineTotal = line.UnitPrice.Mul(line.Quantity)
		if cart.Subtotal > maxTotal-line.LineTotal {
			return Cart{}, fmt.Errorf("cart subtotal exceeds maximum: %w", ErrInvalidAmount)
		}
		cart.Subtotal = cart.Subtotal.Add(line.LineTotal)
		cart.Lines[i] = line
	}

	return cart, nil
}
