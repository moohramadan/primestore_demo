CREATE TABLE orders (
    id               BIGSERIAL PRIMARY KEY,
    order_number     VARCHAR(30) NOT NULL UNIQUE,
    user_id          INTEGER NOT NULL,
    status           VARCHAR(20) NOT NULL DEFAULT 'placed',
    payment_status   VARCHAR(20) NOT NULL DEFAULT 'unpaid',

    ship_full_name   VARCHAR(100) NOT NULL,
    ship_phone       VARCHAR(30)  NOT NULL DEFAULT '',
    ship_line1       VARCHAR(200) NOT NULL,
    ship_line2       VARCHAR(200) NOT NULL DEFAULT '',
    ship_city        VARCHAR(100) NOT NULL,
    ship_state       VARCHAR(100) NOT NULL DEFAULT '',
    ship_postal_code VARCHAR(20)  NOT NULL DEFAULT '',
    ship_country     VARCHAR(100) NOT NULL,

    subtotal         NUMERIC(14, 2) NOT NULL,
    delivery_fee     NUMERIC(14, 2) NOT NULL DEFAULT 0,
    total            NUMERIC(14, 2) NOT NULL,

    paid_at          TIMESTAMPTZ,
    cancelled_at     TIMESTAMPTZ,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT orders_status_valid
        CHECK (status IN ('placed', 'cancelled', 'fulfilled')),
    CONSTRAINT orders_payment_status_valid
        CHECK (payment_status IN ('unpaid', 'paid', 'refunded')),
    CONSTRAINT orders_amounts_non_negative
        CHECK (subtotal >= 0 AND delivery_fee >= 0 AND total >= 0),
    CONSTRAINT orders_total_matches
        CHECK (total = subtotal + delivery_fee),
    CONSTRAINT orders_cancelled_at_matches_status
        CHECK ((status = 'cancelled') = (cancelled_at IS NOT NULL))
);

CREATE INDEX idx_orders_user_created ON orders (user_id, created_at DESC);

CREATE INDEX idx_orders_unpaid_placed ON orders (created_at)
    WHERE payment_status = 'unpaid' AND status = 'placed';

CREATE TABLE order_items (
    id            BIGSERIAL PRIMARY KEY,
    order_id      BIGINT NOT NULL REFERENCES orders (id) ON DELETE CASCADE,
    variant_id    INTEGER NOT NULL,
    product_id    INTEGER NOT NULL,
    seller_id     INTEGER NOT NULL DEFAULT 0,
    product_name  TEXT NOT NULL,
    variant_label TEXT NOT NULL DEFAULT '',
    image_url     TEXT NOT NULL DEFAULT '',
    unit_price    NUMERIC(10, 2) NOT NULL,
    quantity      INTEGER NOT NULL,
    line_total    NUMERIC(14, 2) NOT NULL,

    CONSTRAINT order_items_unit_price_non_negative
        CHECK (unit_price >= 0),
    CONSTRAINT order_items_quantity_positive
        CHECK (quantity > 0),
    CONSTRAINT order_items_line_total_matches
        CHECK (line_total = unit_price * quantity),
    CONSTRAINT order_items_unique_variant
        UNIQUE (order_id, variant_id)
);

CREATE INDEX idx_order_items_seller ON order_items (seller_id, order_id);

CREATE TABLE order_idempotency_keys (
    user_id         INTEGER NOT NULL,
    idempotency_key VARCHAR(100) NOT NULL,
    order_id        BIGINT NOT NULL UNIQUE REFERENCES orders (id) ON DELETE CASCADE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, idempotency_key)
);
