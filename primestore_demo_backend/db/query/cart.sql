-- name: UpsertCartItem :one
-- Add to cart: insert, or add to the quantity if the variant is already there.
INSERT INTO cart_items (user_id, variant_id, quantity)
VALUES ($1, $2, $3)
ON CONFLICT (user_id, variant_id)
DO UPDATE SET
    quantity   = LEAST(cart_items.quantity + EXCLUDED.quantity, sqlc.arg(max_quantity)::int),
    updated_at = now()
RETURNING *;

-- name: SetCartItemQuantity :execrows
-- Set an exact quantity (the +/- buttons in the cart screen).
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
SELECT
    ci.variant_id,
    ci.quantity,
    v.product_id,
    v.color,
    v.size,
    v.stock,
    v.price,
    v.sale_price,
    COALESCE(v.sale_price, v.price)::numeric(10, 2) AS unit_price,
    p.name      AS product_name,
    p.seller_id AS seller_id,
    COALESCE((
        SELECT pi.image_url
        FROM product_images pi
        WHERE pi.product_id = p.id
        ORDER BY pi.sort_order
        LIMIT 1
    ), '')::text AS image_url
FROM cart_items ci
JOIN product_variants v ON v.id = ci.variant_id
JOIN products p         ON p.id = v.product_id
WHERE ci.user_id = $1
ORDER BY ci.created_at DESC;