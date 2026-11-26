-- Order queries for the orders module. They only touch the orders tables.

-- name: InsertOrder :one
INSERT INTO orders (
    order_number, user_id, status, payment_status, stock_ref,
    ship_full_name, ship_phone, ship_line1, ship_line2,
    ship_city, ship_state, ship_postal_code, ship_country,
    subtotal, delivery_fee, total
) VALUES (
    $1, $2, $3, $4, $5,
    $6, $7, $8, $9,
    $10, $11, $12, $13,
    $14, $15, $16
)
RETURNING id, created_at;

-- name: InsertOrderItem :exec
INSERT INTO order_items (
    order_id, variant_id, product_id, seller_id,
    product_name, variant_label, image_url,
    unit_price, quantity, line_total
) VALUES (
    $1, $2, $3, $4,
    $5, $6, $7,
    $8, $9, $10
);

-- name: InsertStatusHistory :exec
INSERT INTO order_status_history (order_id, from_status, to_status, changed_by)
VALUES ($1, $2, $3, $4);

-- name: InsertOutboxEvent :exec
INSERT INTO outbox_events (event_type, aggregate_id, payload)
VALUES ($1, $2, $3);

-- name: InsertIdempotencyKey :execrows
-- Returns 0 when this user already used this key (a repeated or racing request).
INSERT INTO order_idempotency_keys (user_id, idempotency_key, order_id)
VALUES ($1, $2, $3)
ON CONFLICT (user_id, idempotency_key) DO NOTHING;

-- name: GetOrderByIdempotencyKey :one
SELECT o.*
FROM orders o
JOIN order_idempotency_keys k ON k.order_id = o.id
WHERE k.user_id = $1 AND k.idempotency_key = $2;

-- name: ListOrderItems :many
SELECT * FROM order_items
WHERE order_id = $1
ORDER BY id;
