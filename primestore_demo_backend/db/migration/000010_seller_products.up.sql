ALTER TABLE products DROP CONSTRAINT products_seller_id_fkey;
ALTER TABLE products ADD CONSTRAINT products_seller_id_fkey
    FOREIGN KEY (seller_id) REFERENCES seller_profiles(id) ON DELETE CASCADE;
CREATE INDEX idx_products_seller_id ON products(seller_id);