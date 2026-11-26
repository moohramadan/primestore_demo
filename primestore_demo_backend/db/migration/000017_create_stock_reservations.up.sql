CREATE TABLE stock_reservations (
    id         BIGSERIAL PRIMARY KEY,
    ref        VARCHAR(64) NOT NULL,
    variant_id INTEGER NOT NULL REFERENCES product_variants (id) ON DELETE CASCADE,
    quantity   INTEGER NOT NULL CHECK (quantity > 0),
    status     VARCHAR(12) NOT NULL DEFAULT 'reserved'
                   CHECK (status IN ('reserved', 'committed', 'released')),
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (ref, variant_id)
);

CREATE INDEX idx_stock_reservations_expired
    ON stock_reservations (expires_at)
    WHERE status = 'reserved';

ALTER TABLE product_variants
    ADD CONSTRAINT product_variants_stock_nonnegative
    CHECK (stock >= 0);
