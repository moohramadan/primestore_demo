-- Stock reservations for the orders module (inventory side).
-- A reservation row records stock that was taken for a checkout (ref) so it can
-- be committed, released, or released automatically when it expires.

-- name: InsertReservation :execrows
-- Returns 1 when a new reservation row was created, 0 when (ref, variant_id)
-- already exists (a retry of the same checkout).
INSERT INTO stock_reservations (ref, variant_id, quantity, expires_at)
VALUES ($1, $2, $3, now() + (sqlc.arg(ttl_seconds)::int * interval '1 second'))
ON CONFLICT (ref, variant_id) DO NOTHING;

-- name: DecrementVariantStock :execrows
-- The atomic "take stock" step. 0 rows affected means not enough stock.
UPDATE product_variants
SET stock = stock - sqlc.arg(quantity)::int
WHERE id = sqlc.arg(variant_id)::int
  AND stock >= sqlc.arg(quantity)::int;

-- name: IncrementVariantStock :exec
UPDATE product_variants
SET stock = stock + sqlc.arg(quantity)::int
WHERE id = sqlc.arg(variant_id)::int;

-- name: GetReservation :one
SELECT * FROM stock_reservations
WHERE ref = $1 AND variant_id = $2;

-- name: ReleaseReservations :many
-- Only touches rows still 'reserved', so calling it twice returns nothing the
-- second time. The caller adds the returned quantities back to stock.
UPDATE stock_reservations
SET status = 'released', updated_at = now()
WHERE ref = $1 AND status = 'reserved'
RETURNING variant_id, quantity;

-- name: CommitReservations :execrows
UPDATE stock_reservations
SET status = 'committed', updated_at = now()
WHERE ref = $1 AND status = 'reserved';

-- name: ListReservationStatuses :many
SELECT status FROM stock_reservations WHERE ref = $1;

-- name: ListExpiredReservationRefs :many
SELECT DISTINCT ref
FROM stock_reservations
WHERE status = 'reserved' AND expires_at < now()
LIMIT sqlc.arg(max_rows)::int;