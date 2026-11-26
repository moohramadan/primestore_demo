-- The reservation reference that holds this order's stock. Phase 6 uses it to
-- return the stock when an order is cancelled, and a reconciler can use it to
-- find orders whose reservation was never committed.
ALTER TABLE orders ADD COLUMN stock_ref VARCHAR(64) NOT NULL DEFAULT '';
