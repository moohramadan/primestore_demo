DROP TABLE product_variants;
DROP TABLE product_images;

ALTER TABLE products ADD COLUMN price NUMERIC(10, 2);
ALTER TABLE products ADD COLUMN stock_qty INT NOT NULL DEFAULT 0;
ALTER TABLE products ADD COLUMN image_url TEXT;

ALTER TABLE products
    DROP COLUMN brand_id,
    DROP COLUMN is_featured;

ALTER TABLE products ALTER COLUMN seller_id SET NOT NULL;

DROP TABLE brands;
