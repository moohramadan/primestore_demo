package store

import (
	"context"
	"fmt"

	"primestore_demo_backend/internal/orders/domain"
	"primestore_demo_backend/internal/orders/store/gen"
)

func (s *Store) UpsertCartItem(ctx context.Context, userID, variantID, quantity, maxQuantity int32) (int32, error) {
	row, err := s.q.UpsertCartItem(ctx, gen.UpsertCartItemParams{
		UserID:      userID,
		VariantID:   variantID,
		Quantity:    quantity,
		MaxQuantity: maxQuantity,
	})
	if err != nil {
		return 0, fmt.Errorf("upsert cart item: %w", err)
	}
	return row.Quantity, nil
}

func (s *Store) SetCartItemQuantity(ctx context.Context, userID, variantID, quantity int32) (bool, error) {
	rows, err := s.q.SetCartItemQuantity(ctx, gen.SetCartItemQuantityParams{
		UserID:    userID,
		VariantID: variantID,
		Quantity:  quantity,
	})
	if err != nil {
		return false, fmt.Errorf("set cart item quantity: %w", err)
	}
	return rows > 0, nil
}

func (s *Store) RemoveCartItem(ctx context.Context, userID, variantID int32) (bool, error) {
	rows, err := s.q.RemoveCartItem(ctx, gen.RemoveCartItemParams{
		UserID:    userID,
		VariantID: variantID,
	})
	if err != nil {
		return false, fmt.Errorf("remove cart item: %w", err)
	}
	return rows > 0, nil
}

func (s *Store) ListCartItems(ctx context.Context, userID int32) ([]domain.CartEntry, error) {
	rows, err := s.q.ListCartItems(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("list cart items: %w", err)
	}

	entries := make([]domain.CartEntry, len(rows))
	for i, r := range rows {
		entries[i] = domain.CartEntry{VariantID: r.VariantID, Quantity: r.Quantity}
	}
	return entries, nil
}

func (s *Store) ClearCart(ctx context.Context, userID int32) error {
	if err := s.q.ClearCart(ctx, userID); err != nil {
		return fmt.Errorf("clear cart: %w", err)
	}
	return nil
}
