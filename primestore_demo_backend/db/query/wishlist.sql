-- name: AddToWishlist :one
INSERT INTO wishlists (user_id, product_id)
VALUES ($1, $2)
ON CONFLICT (user_id, product_id) DO NOTHING
RETURNING *;

-- name: RemoveFromWishlist :exec
DELETE FROM wishlists
WHERE user_id = $1 AND product_id = $2;

-- name: ListWishlistProducts :many
SELECT p.*, b.name AS brand_name, b.is_verified AS brand_verified
FROM products p
LEFT JOIN brands b ON p.brand_id = b.id
JOIN wishlists w ON w.product_id = p.id
WHERE w.user_id = $1
ORDER BY w.created_at DESC;


-- name: ListWishlistedProductIDs :many
SELECT product_id
FROM wishlists
WHERE user_id = $1;
