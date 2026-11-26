// Package store is the orders module's persistence layer. It uses its own sqlc
// package (internal/orders/store/gen, generated from internal/orders/store/queries)
// and only ever touches the orders tables.
package store

import (
	"database/sql"

	"primestore_demo_backend/internal/orders/service"
	"primestore_demo_backend/internal/orders/store/gen"
)

// Store implements service.CartStore (and, in later phases, the order store).
type Store struct {
	conn *sql.DB // used for transactions in the checkout phase
	q    *gen.Queries
}

var _ service.CartStore = (*Store)(nil)

// New creates a Store on top of an open database connection.
func New(conn *sql.DB) *Store {
	return &Store{conn: conn, q: gen.New(conn)}
}
