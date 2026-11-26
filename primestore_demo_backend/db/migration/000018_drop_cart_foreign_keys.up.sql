-- The cart belongs to the orders module, which must not be tied to other modules'
-- tables (docs/adr-001-orders-module.md, rule 4). The service now checks that a
-- variant exists through the Catalog port instead of relying on this foreign key.
ALTER TABLE cart_items DROP CONSTRAINT IF EXISTS cart_items_user_id_fkey;
ALTER TABLE cart_items DROP CONSTRAINT IF EXISTS cart_items_variant_id_fkey;
