package service

import (
	"context"
	"fmt"

	"primestore_demo_backend/internal/orders/domain"
)

// CartStore is what the cart use cases need from storage. It only knows about
// cart rows (which variant, how many), never about prices or products.
type CartStore interface {
	// UpsertCartItem adds quantity to the line (creating it if needed), capped at
	// maxQuantity, and returns the resulting quantity.
	UpsertCartItem(ctx context.Context, userID, variantID, quantity, maxQuantity int32) (int32, error)
	// SetCartItemQuantity sets an exact quantity. found is false when the user
	// has no such line.
	SetCartItemQuantity(ctx context.Context, userID, variantID, quantity int32) (found bool, err error)
	// RemoveCartItem deletes a line. found is false when the user has no such line.
	RemoveCartItem(ctx context.Context, userID, variantID int32) (found bool, err error)
	// ListCartItems returns the user's lines, newest first.
	ListCartItems(ctx context.Context, userID int32) ([]domain.CartEntry, error)
	// ClearCart removes every line of the user's cart.
	ClearCart(ctx context.Context, userID int32) error
}

func checkUser(userID int32) error {
	if userID < 1 {
		return fmt.Errorf("user id %d: %w", userID, domain.ErrInvalidUser)
	}
	return nil
}

// AddToCart adds quantity units of a variant and returns the resulting quantity
// of that line (which may be lower than the sum asked for, because a line never
// holds more than domain.MaxCartQuantity).
func (s *Service) AddToCart(ctx context.Context, userID, variantID, quantity int32) (int32, error) {
	if err := checkUser(userID); err != nil {
		return 0, err
	}
	if err := domain.ValidateCartQuantity(quantity); err != nil {
		return 0, err
	}
	if variantID < 1 {
		return 0, fmt.Errorf("variant %d: %w", variantID, domain.ErrNotFound)
	}

	// The variant must exist. This replaces the foreign key the cart used to have.
	variants, err := s.catalog.GetVariants(ctx, []int32{variantID})
	if err != nil {
		return 0, fmt.Errorf("add to cart: %w", err)
	}
	if _, ok := variants[variantID]; !ok {
		return 0, fmt.Errorf("variant %d: %w", variantID, domain.ErrNotFound)
	}

	resulting, err := s.cart.UpsertCartItem(ctx, userID, variantID, quantity, domain.MaxCartQuantity)
	if err != nil {
		return 0, fmt.Errorf("add to cart: %w", err)
	}
	return resulting, nil
}

// SetQuantity sets the exact quantity of a line already in the cart.
func (s *Service) SetQuantity(ctx context.Context, userID, variantID, quantity int32) error {
	if err := checkUser(userID); err != nil {
		return err
	}
	if variantID < 1 {
		return fmt.Errorf("variant %d: %w", variantID, domain.ErrNotFound)
	}
	if err := domain.ValidateCartQuantity(quantity); err != nil {
		return err
	}

	found, err := s.cart.SetCartItemQuantity(ctx, userID, variantID, quantity)
	if err != nil {
		return fmt.Errorf("set cart quantity: %w", err)
	}
	if !found {
		return fmt.Errorf("variant %d not in cart: %w", variantID, domain.ErrNotFound)
	}
	return nil
}

// RemoveItem deletes a line from the cart.
func (s *Service) RemoveItem(ctx context.Context, userID, variantID int32) error {
	if err := checkUser(userID); err != nil {
		return err
	}
	if variantID < 1 {
		return fmt.Errorf("variant %d: %w", variantID, domain.ErrNotFound)
	}

	found, err := s.cart.RemoveCartItem(ctx, userID, variantID)
	if err != nil {
		return fmt.Errorf("remove cart item: %w", err)
	}
	if !found {
		return fmt.Errorf("variant %d not in cart: %w", variantID, domain.ErrNotFound)
	}
	return nil
}

// GetCart returns the user's cart with current catalog data and calculated
// totals. Prices always come from the catalog, never from the cart row. Lines
// whose variant no longer exists are left out and removed from the cart.
func (s *Service) GetCart(ctx context.Context, userID int32) (domain.Cart, error) {
	if err := checkUser(userID); err != nil {
		return domain.Cart{}, err
	}

	entries, err := s.cart.ListCartItems(ctx, userID)
	if err != nil {
		return domain.Cart{}, fmt.Errorf("get cart: %w", err)
	}
	if len(entries) == 0 {
		return domain.BuildCart(nil)
	}

	ids := make([]int32, len(entries))
	for i, e := range entries {
		ids[i] = e.VariantID
	}
	variants, err := s.catalog.GetVariants(ctx, ids)
	if err != nil {
		return domain.Cart{}, fmt.Errorf("get cart: %w", err)
	}

	lines := make([]domain.CartLine, 0, len(entries))
	var stale []int32
	for _, e := range entries {
		v, ok := variants[e.VariantID]
		if !ok {
			stale = append(stale, e.VariantID)
			continue
		}
		lines = append(lines, domain.CartLine{
			VariantID:   v.VariantID,
			ProductID:   v.ProductID,
			SellerID:    v.SellerID,
			ProductName: v.ProductName,
			Color:       v.Color,
			Size:        v.Size,
			ImageURL:    v.ImageURL,
			UnitPrice:   v.UnitPrice,
			Quantity:    e.Quantity,
			InStock:     v.Stock >= e.Quantity,
		})
	}

	// Remove rows whose variants disappeared after cart items were decoupled
	// from catalog foreign keys.
	for _, variantID := range stale {
		if _, err := s.cart.RemoveCartItem(ctx, userID, variantID); err != nil {
			return domain.Cart{}, fmt.Errorf("remove stale variant %d from cart: %w", variantID, err)
		}
	}

	cart, err := domain.BuildCart(lines)
	if err != nil {
		return domain.Cart{}, fmt.Errorf("get cart: %w", err)
	}
	return cart, nil
}
