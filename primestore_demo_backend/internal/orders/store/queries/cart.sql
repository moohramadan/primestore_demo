-- Cart queries for the orders module. They only touch cart_items. Anything about
-- a variant (name, price, stock) comes from the Catalog port, never from a join.

-- name: UpsertCartItem :one
-- Add to cart: insert, or add to the quantity when the variant is already there,
-- capped at max_quantity. Returns the resulting quantity.
INSERT INTO cart_items (user_id, variant_id, quantity)
VALUES ($1, $2, $3)
ON CONFLICT (user_id, variant_id)
DO UPDATE SET
    quantity   = LEAST(cart_items.quantity + EXCLUDED.quantity, sqlc.arg(max_quantity)::int),
    updated_at = now()
RETURNING variant_id, quantity;

-- name: SetCartItemQuantity :execrows
UPDATE cart_items
SET quantity = $3, updated_at = now()
WHERE user_id = $1 AND variant_id = $2;

-- name: RemoveCartItem :execrows
DELETE FROM cart_items
WHERE user_id = $1 AND variant_id = $2;

-- name: ClearCart :exec
DELETE FROM cart_items
WHERE user_id = $1;

-- name: ListCartItems :many
SELECT variant_id, quantity
FROM cart_items
WHERE user_id = $1
ORDER BY created_at DESC, variant_id;
