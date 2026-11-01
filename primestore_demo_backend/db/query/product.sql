-- name: ListFeaturedProducts :many
SELECT p.*, b.name AS brand_name, b.is_verified AS brand_verified,
       COALESCE(c.name, '') AS category_name
FROM products p
LEFT JOIN brands b ON p.brand_id = b.id
LEFT JOIN categories c ON p.category_id = c.id
WHERE p.is_featured = true
ORDER BY p.id;

-- name: ListProductsByCategory :many
SELECT p.*, b.name AS brand_name, b.is_verified AS brand_verified,
       COALESCE(c.name, '') AS category_name
FROM products p
LEFT JOIN brands b ON p.brand_id = b.id
LEFT JOIN categories c ON c.id = p.category_id
WHERE p.category_id = $1
ORDER BY p.id;

-- name: ListSellerProducts :many
SELECT p.id, p.category_id, p.brand_id, p.name, p.description, p.is_featured,
       COALESCE(b.name, '') AS brand_name,
       COALESCE(b.is_verified, false) AS brand_verified,
       COALESCE(c.name, '') AS category_name
FROM products p
LEFT JOIN brands b ON b.id = p.brand_id
LEFT JOIN categories c ON c.id = p.category_id
WHERE p.seller_id = $1
ORDER BY p.id DESC;

-- name: GetProduct :one
SELECT p.*, b.name AS brand_name, b.is_verified AS brand_verified,
       COALESCE(c.name, '') AS category_name
FROM products p
LEFT JOIN brands b ON p.brand_id = b.id
LEFT JOIN categories c ON p.category_id = c.id
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

-- name: IsProductImageReferenced :one
SELECT EXISTS (
    SELECT 1 FROM product_images WHERE image_url = $1
);

-- name: CreateProductVariant :exec
INSERT INTO product_variants (product_id, color, size, price, sale_price, discount_percent, stock)
VALUES ($1, $2, $3, $4, $5, $6, $7);

-- name: UpdateSellerProduct :execrows
UPDATE products
SET name = $3, description = $4, category_id = $5, brand_id = $6
WHERE id = $1 AND seller_id = $2;

-- name: UpdateSellerProductVariant :execrows
UPDATE product_variants AS v
SET color = $4, size = $5, price = $6, sale_price = $7,
    discount_percent = $8, stock = $9
FROM products AS p
WHERE v.id = $1 AND v.product_id = $2
  AND p.id = v.product_id AND p.seller_id = $3;
