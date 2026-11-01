-- name: CreateAddress :one
INSERT INTO addresses (
    user_id,
    full_name,
    phone,
    address_line_1,
    address_line_2,
    city,
    state,
    postal_code,
    country,
    is_default
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10
) RETURNING *;

-- name: ListAddressesByUser :many
SELECT * FROM addresses
WHERE user_id = $1
ORDER BY is_default DESC, created_at DESC;

-- name: SetDefaultAddress :execrows
UPDATE addresses AS a
SET is_default = (a.id = $2)
WHERE a.user_id = $1
  AND EXISTS (
    SELECT 1 FROM addresses AS b WHERE b.id = $2 AND b.user_id = $1
  );
