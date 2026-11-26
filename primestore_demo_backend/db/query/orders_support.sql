-- Read-only queries used by the orders module's adapters (stage 1 only).
-- In stage 2 these live behind the catalog and user services.

-- name: GetVariantsForOrder :many
-- Everything checkout needs to know about the variants in a cart, with the
-- effective price (sale price when set).
SELECT
    v.id         AS variant_id,
    v.product_id AS product_id,
    p.seller_id  AS seller_id,
    p.name       AS product_name,
    v.color      AS color,
    v.size       AS size,
    COALESCE(v.sale_price, v.price)::numeric(10, 2) AS unit_price,
    v.stock      AS stock,
    COALESCE((
        SELECT pi.image_url
        FROM product_images pi
        WHERE pi.product_id = p.id
        ORDER BY pi.sort_order
        LIMIT 1
    ), '')::text AS image_url
FROM product_variants v
JOIN products p ON p.id = v.product_id
WHERE v.id = ANY(sqlc.arg(variant_ids)::int[])
ORDER BY v.id;

-- name: GetAddressForUser :one
-- The user_id check means someone else's address looks exactly like a missing one.
SELECT * FROM addresses
WHERE id = $1 AND user_id = $2;