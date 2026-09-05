-- name: CreateUser :one
INSERT INTO users (
  name, email, password_hash, phone
) VALUES (
  $1, $2, $3, $4
) RETURNING *;

-- name: GetUser :one
SELECT * FROM users
WHERE id = $1 LIMIT 1;

-- name: GetUserByEmail :one
SELECT * FROM users
WHERE email = $1 LIMIT 1;

-- name: GetUserByPhone :one
SELECT * FROM users
WHERE phone = $1 LIMIT 1;

-- name: ListUsers :many
SELECT * FROM users
ORDER BY id
LIMIT $1
OFFSET $2;

-- name: UpdateUserPhone :one
UPDATE users
SET phone = $2
WHERE id = $1
RETURNING *;

-- name: DeleteUser :exec
DELETE FROM users
WHERE id = $1;

-- name: VerifyUserEmail :exec
UPDATE users
SET is_verified = true
WHERE id = $1;

