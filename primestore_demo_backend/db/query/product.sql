-- name: ListFeaturedProducts :many
SELECT p.*, b.name AS brand_name, b.is_verified AS brand_verified
FROM products p
LEFT JOIN brands b ON p.brand_id = b.id
WHERE p.is_featured = true
ORDER BY p.id;

-- name: ListProductsByCategory :many
SELECT p.*, b.name AS brand_name, b.is_verified AS brand_verified
FROM products p
LEFT JOIN brands b ON p.brand_id = b.id
WHERE p.category_id = $1
ORDER BY p.id;

-- name: GetProduct :one
SELECT p.*, b.name AS brand_name, b.is_verified AS brand_verified
FROM products p
LEFT JOIN brands b ON p.brand_id = b.id
WHERE p.id = $1;

-- name: ListProductImages :many
SELECT * FROM product_images WHERE product_id = $1 ORDER BY sort_order;

-- name: ListProductVariants :many
SELECT * FROM product_variants WHERE product_id = $1 ORDER BY id;

-- name: ListProductImagesByProductIDs :many
SELECT * FROM product_images
WHERE product_id = ANY(sqlc.arg(product_ids)::int[])
ORDER BY product_id, sort_order;

-- name: ListProductVariantsByProductIDs :many
SELECT * FROM product_variants
WHERE product_id = ANY(sqlc.arg(product_ids)::int[])
ORDER BY product_id, id;

-- name: CreateProduct :one
INSERT INTO products (seller_id, category_id, brand_id, name, description)
VALUES ($1, $2, $3, $4, $5) RETURNING *;

-- name: CreateProductImage :exec
INSERT INTO product_images (product_id, image_url, sort_order)
VALUES ($1, $2, $3);

-- name: CreateProductVariant :exec
INSERT INTO product_variants (product_id, color, size, price, discount_percent, stock)
VALUES ($1, $2, $3, $4, $5, $6);

