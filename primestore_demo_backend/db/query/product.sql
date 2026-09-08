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
