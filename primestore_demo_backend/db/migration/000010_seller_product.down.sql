DROP INDEX idx_products_seller_id;
ALTER TABLE products DROP CONSTRAINT products_seller_id_fkey;
UPDATE products SET seller_id = NULL;
ALTER TABLE products ADD CONSTRAINT products_seller_id_fkey
    FOREIGN KEY (seller_id) REFERENCES users(id);