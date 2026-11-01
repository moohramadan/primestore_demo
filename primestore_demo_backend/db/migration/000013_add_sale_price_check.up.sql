-- A sale price can never be negative or higher than the original price.
-- NULL means "not on sale".
ALTER TABLE product_variants
    ADD CONSTRAINT product_variants_sale_price_check
    CHECK (sale_price IS NULL OR (sale_price >= 0 AND sale_price <= price));
