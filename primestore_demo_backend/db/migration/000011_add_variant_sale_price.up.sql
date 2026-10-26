ALTER TABLE product_variants
    ADD COLUMN sale_price NUMERIC(10, 2);

UPDATE product_variants
SET sale_price = ROUND(price * (100 - discount_percent) / 100, 2)
WHERE discount_percent > 0;
