-- name: CreateSellerProfile :one
INSERT INTO seller_profiles (
    user_id,
    account_type,
    business_name,
    business_phone,
    business_address
) VALUES (
    $1, $2, $3, $4, $5
) RETURNING *;

-- name: GetSellerProfileByUserID :one
SELECT * FROM seller_profiles
WHERE user_id = $1
LIMIT 1;

-- name: GetSellerProfileBySellerID :one
SELECT * FROM seller_profiles
WHERE id = $1
LIMIT 1;

-- name: CreatePayoutAccount :exec
INSERT INTO seller_payout_accounts (
    seller_id,
    account_holder_name,
    bank_name,
    account_number
) VALUES (
    $1, $2, $3, $4
);

-- name: GetPayoutAccountBySellerID :one
SELECT * FROM seller_payout_accounts
WHERE seller_id = $1;



