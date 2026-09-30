INSERT INTO categories (name, icon) VALUES
  ('All', 'grid'),
  ('Audio', 'headphones'),
  ('Wearables', 'watch'),
  ('Footwear', 'shoe');

INSERT INTO brands (name, logo_url, is_verified) VALUES
  ('Nike', 'assets/images/products/AQCOWmlxbEucCRd9Q5A_hEg5RrAHsBEqbjrCFCv8BLMemJTZf-2muU8sCNqDNv-F6wueDmZ2GmBr-D_03SfRpGg2vw8aHLcVt_VpefsnRrVDHSa0OGQ3lVo_wyvRN_qKY8AJxIRlXNlBSUbV-iOjqG5sVV0AY6Ap8bMNyTKmtF4.jpeg', true);

INSERT INTO products (category_id, brand_id, name, description, is_featured) VALUES
  (
    (SELECT id FROM categories WHERE name = 'Footwear'),
    (SELECT id FROM brands WHERE name = 'Nike'),
    'Ash Air Runnner 5',
    'This is a Product description for White Air max 7. There are more things that can be added but I am just practicing and nothing else.',
    true
  );

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
  ((SELECT id FROM products WHERE name = 'Ash Air Runnner 5'), 'assets/images/products/AQCOWmlxbEucCRd9Q5A_hEg5RrAHsBEqbjrCFCv8BLMemJTZf-2muU8sCNqDNv-F6wueDmZ2GmBr-D_03SfRpGg2vw8aHLcVt_VpefsnRrVDHSa0OGQ3lVo_wyvRN_qKY8AJxIRlXNlBSUbV-iOjqG5sVV0AY6Ap8bMNyTKmtF4.jpeg', 0),
  ((SELECT id FROM products WHERE name = 'Ash Air Runnner 5'), 'assets/images/products/AQCOWmlxbEucCRd9Q5A_hEg5RrAHsBEqbjrCFCv8BLMemJTZf-2muU8sCNqDNv-F6wueDmZ2GmBr-D_03SfRpGg2vw8aHLcVt_VpefsnRrVDHSa0OGQ3lVo_wyvRN_qKY8AJxIRlXNlBSUbV-iOjqG5sVV0AY6Ap8bMNyTKmtF4.jpeg', 1);

INSERT INTO product_variants (product_id, color, size, price, discount_percent, stock) VALUES
  ((SELECT id FROM products WHERE name = 'Ash Air Runnner 5'), 'Green', 'EU 34', 250.00, 25, 12),
  ((SELECT id FROM products WHERE name = 'Ash Air Runnner 5'), 'Green', 'EU 36', 250.00, 25, 8),
  ((SELECT id FROM products WHERE name = 'Ash Air Runnner 5'), 'Blue', 'EU 34', 250.00, 25, 5),
  ((SELECT id FROM products WHERE name = 'Ash Air Runnner 5'), 'Red', 'EU 34', 250.00, 25, 0);
