CREATE TABLE outbox_events (
    id           BIGSERIAL PRIMARY KEY,
    event_type   VARCHAR(50) NOT NULL,
    aggregate_id BIGINT NOT NULL,
    payload      JSONB NOT NULL,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    published_at TIMESTAMPTZ
);

CREATE INDEX idx_outbox_events_unpublished
    ON outbox_events (id)
    WHERE published_at IS NULL;

CREATE TABLE order_status_history (
    id         BIGSERIAL PRIMARY KEY,
    order_id   BIGINT NOT NULL REFERENCES orders (id) ON DELETE CASCADE,
    from_status VARCHAR(20),
    to_status   VARCHAR(20) NOT NULL,
    changed_by INTEGER, -- NULL for system-initiated changes.
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT order_status_history_from_status_valid
        CHECK (from_status IS NULL OR from_status IN ('placed', 'cancelled', 'fulfilled')),
    CONSTRAINT order_status_history_to_status_valid
        CHECK (to_status IN ('placed', 'cancelled', 'fulfilled'))
);

CREATE INDEX idx_order_status_history_order
    ON order_status_history (order_id, id);
