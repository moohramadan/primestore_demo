package domain

import (
	"errors"
	"fmt"
)

// Domain errors. The HTTP layer (and later the gRPC layer) maps these to status
// codes. The domain and service code never mention HTTP.
var (
	ErrEmptyCart             = errors.New("cart is empty")
	ErrNotFound              = errors.New("not found")
	ErrInvalidTransition     = errors.New("invalid status transition")
	ErrOutOfStock            = errors.New("not enough stock")
	ErrQuantityLimit         = errors.New("quantity out of range")
	ErrInvalidAmount         = errors.New("invalid amount")
	ErrDuplicateVariant      = errors.New("duplicate variant in order")
	ErrInvalidUser           = errors.New("invalid user")
	ErrReservationExpired    = errors.New("stock reservation expired or was released")
	ErrIdempotencyKeyReused  = errors.New("idempotency key already used")
	ErrOrderNumberTaken      = errors.New("order number already taken")
	ErrInvalidIdempotencyKey = errors.New("invalid idempotency key")
	ErrItemUnavailable       = errors.New("item no longer available")
)

// OutOfStockError says WHICH variant could not be reserved, so the app can
// highlight it. It matches ErrOutOfStock with errors.Is, and callers who need
// the id use errors.As:
//
//	var oos *domain.OutOfStockError
//	if errors.As(err, &oos) { ... oos.VariantID ... }
type OutOfStockError struct {
	VariantID int32
}

func (e *OutOfStockError) Error() string {
	return fmt.Sprintf("variant %d: %s", e.VariantID, ErrOutOfStock)
}

func (e *OutOfStockError) Is(target error) bool {
	return target == ErrOutOfStock
}

// ItemUnavailableError says which cart item can no longer be bought (deleted
// from the catalog, or without a valid price). It matches ErrItemUnavailable.
type ItemUnavailableError struct {
	VariantID int32
}

func (e *ItemUnavailableError) Error() string {
	return fmt.Sprintf("variant %d: %s", e.VariantID, ErrItemUnavailable)
}

func (e *ItemUnavailableError) Is(target error) bool {
	return target == ErrItemUnavailable
}
