package orders

import (
	"context"

	"primestore_demo_backend/internal/orders/domain"
)

// These interfaces are the ONLY way the orders module talks to the rest of the
// app. In stage 1 they are implemented in internal/orders/adapters by calling
// existing code. In stage 2 they become gRPC clients and nothing else changes.

// VariantInfo is what orders needs to know about a purchasable variant.
// SellerID is 0 when the product has no seller.
type VariantInfo struct {
	VariantID   int32
	ProductID   int32
	SellerID    int32
	ProductName string
	Color       string
	Size        string
	ImageURL    string       // already a public URL
	UnitPrice   domain.Money // already the effective price: sale price if set
	Stock       int32
}

type Catalog interface {
	// GetVariants returns info for the ids that exist. Missing ids are simply
	// absent from the map (the service decides how to react).
	GetVariants(ctx context.Context, ids []int32) (map[int32]VariantInfo, error)
}

type ReserveItem struct {
	VariantID int32
	Quantity  int32
}

type Inventory interface {
	// Reserve holds stock for ref: all items or none. It is atomic, safe to retry
	// with the same ref and items, and the hold expires by itself if never
	// committed. Returns an error matching domain.ErrOutOfStock when stock is short.
	Reserve(ctx context.Context, ref string, items []ReserveItem) error
	// Commit makes a reservation permanent. Returns domain.ErrReservationExpired
	// if it was already released.
	Commit(ctx context.Context, ref string) error
	// Release gives the stock back. Calling it twice is harmless, and it never
	// touches a committed reservation.
	Release(ctx context.Context, ref string) error
}

type Address struct {
	FullName   string
	Phone      string
	Line1      string
	Line2      string
	City       string
	State      string
	PostalCode string
	Country    string
}

type Addresses interface {
	// Get returns the address only if it belongs to userID, otherwise
	// domain.ErrNotFound (never reveal that someone else's address exists).
	Get(ctx context.Context, userID int32, addressID int64) (Address, error)
}
