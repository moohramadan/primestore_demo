package adapters

import (
	"context"
	"database/sql"
	"errors"
	"fmt"

	db "primestore_demo_backend/db/sqlc"
	"primestore_demo_backend/internal/orders"
	"primestore_demo_backend/internal/orders/domain"
)

// AddressesAdapter implements orders.Addresses using the existing addresses table.
type AddressesAdapter struct {
	q *db.Queries
}

var _ orders.Addresses = (*AddressesAdapter)(nil)

func NewAddressesAdapter(q *db.Queries) *AddressesAdapter {
	return &AddressesAdapter{q: q}
}

// Get returns the address only if it belongs to userID. Someone else's address
// and a missing address both give domain.ErrNotFound.
func (a *AddressesAdapter) Get(ctx context.Context, userID int32, addressID int64) (orders.Address, error) {
	row, err := a.q.GetAddressForUser(ctx, db.GetAddressForUserParams{
		ID:     addressID,
		UserID: int64(userID),
	})
	if errors.Is(err, sql.ErrNoRows) {
		return orders.Address{}, fmt.Errorf("address %d: %w", addressID, domain.ErrNotFound)
	}
	if err != nil {
		return orders.Address{}, fmt.Errorf("get address %d: %w", addressID, err)
	}

	return orders.Address{
		FullName:   row.FullName,
		Phone:      row.Phone,
		Line1:      row.AddressLine1,
		Line2:      row.AddressLine2.String,
		City:       row.City,
		State:      row.State,
		PostalCode: row.PostalCode,
		Country:    row.Country,
	}, nil
}
