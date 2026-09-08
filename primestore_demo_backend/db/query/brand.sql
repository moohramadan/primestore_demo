-- name: GetBrand :one
SELECT * FROM brands WHERE id = $1;
