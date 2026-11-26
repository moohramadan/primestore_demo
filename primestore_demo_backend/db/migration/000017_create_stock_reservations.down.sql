DROP TABLE IF EXISTS stock_reservations;

ALTER TABLE product_variants
    DROP CONSTRAINT IF EXISTS product_variants_stock_nonnegative;
