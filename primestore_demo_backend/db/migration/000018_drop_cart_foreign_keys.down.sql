-- Rows that point at a deleted user or variant would make the constraints fail.
DELETE FROM cart_items
WHERE user_id NOT IN (SELECT id FROM users)
   OR variant_id NOT IN (SELECT id FROM product_variants);

ALTER TABLE cart_items
    ADD CONSTRAINT cart_items_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE;
ALTER TABLE cart_items
    ADD CONSTRAINT cart_items_variant_id_fkey
    FOREIGN KEY (variant_id) REFERENCES product_variants (id) ON DELETE CASCADE;
