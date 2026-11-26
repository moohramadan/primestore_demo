// Package adapters holds the stage-1, in-process implementations of the ports in
// package orders. This is the ONLY place in internal/orders allowed to import
// db/sqlc or other app code.
//
// TODO(phase 3): catalog.go    -> implements orders.Catalog   (wrap your product/variant queries)
// TODO(phase 3): inventory.go  -> implements orders.Inventory (stock_reservations + atomic decrement)
// TODO(phase 3): addresses.go  -> implements orders.Addresses (wrap your address query)
//
// Hints:
//   - Reserve, per item, in ONE transaction:
//     UPDATE product_variants SET stock = stock - $qty WHERE id = $id AND stock >= $qty
//     use :execrows. 0 rows affected means out of stock, so roll back everything.
//   - Process items in ascending variant_id order. Two checkouts locking the same
//     rows in different orders can deadlock.
//   - Record each reservation row (ref, variant_id, quantity, expires_at) in the
//     same transaction so Release knows what to give back.
//   - Add the compile-time check: var _ orders.Catalog = (*CatalogAdapter)(nil)
//     so a wrong signature fails at build time, not at runtime.
//
// Stage 2: this whole package is replaced by gRPC clients.
package adapters
