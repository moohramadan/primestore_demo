-- name: GetBrand :one
SELECT * FROM brands WHERE id = $1;

-- name: ListBrands :many
SELECT * FROM brands ORDER BY name;
