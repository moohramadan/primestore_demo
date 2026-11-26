// Package service holds the use cases of the orders module. It depends only on
// the domain package and on interfaces: CartStore (persistence) and the ports
// defined in package orders (Catalog, and later Inventory and Addresses). That is
// what lets the tests run with in-memory fakes and no database.
package service

import "primestore_demo_backend/internal/orders"

// Service implements the orders use cases.
type Service struct {
	cart    CartStore
	catalog orders.Catalog
}

// New creates the service. Later phases add more dependencies here.
func New(cart CartStore, catalog orders.Catalog) *Service {
	return &Service{cart: cart, catalog: catalog}
}
