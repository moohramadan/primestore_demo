INSERT INTO categories (name, icon) VALUES
  ('All', 'grid'),
  ('Audio', 'headphones'),
  ('Wearables', 'watch'),
  ('Footwear', 'shoe');

INSERT INTO brands (name, logo_url, is_verified) VALUES
  ('Nike', 'https://drive.google.com/file/d/1QYjaKuDamXy6Jd8Ix2ZlgH3kd81q04-V/view?usp=drivesdk', true);

INSERT INTO products (category_id, brand_id, name, description, is_featured) VALUES
  (
    (SELECT id FROM categories WHERE name = 'Footwear'),
    (SELECT id FROM brands WHERE name = 'Nike'),
    'Green Nike Air Max 270 React ENG',
    'This is a Product description for Green Nike Air Max. There are more things that can be added but I am just practicing and nothing else.',
    true
  );

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
  ((SELECT id FROM products WHERE name = 'Green Nike Air Max 270 React ENG'), 'https://drive.google.com/file/d/1oQT4RSRuGYcO895sNSNy7-UB_zxMzhMX/view?usp=drivesdk', 0),
  ((SELECT id FROM products WHERE name = 'Green Nike Air Max 270 React ENG'), 'https://drive.google.com/file/d/1wWF-orIeU4DHF990ejCpr05CzCuueZLB/view?usp=drivesdk', 1);

INSERT INTO product_variants (product_id, color, size, price, discount_percent, stock) VALUES
  ((SELECT id FROM products WHERE name = 'Green Nike Air Max 270 React ENG'), 'Green', 'EU 34', 250.00, 25, 12),
  ((SELECT id FROM products WHERE name = 'Green Nike Air Max 270 React ENG'), 'Green', 'EU 36', 250.00, 25, 8),
  ((SELECT id FROM products WHERE name = 'Green Nike Air Max 270 React ENG'), 'Blue', 'EU 34', 250.00, 25, 5),
  ((SELECT id FROM products WHERE name = 'Green Nike Air Max 270 React ENG'), 'Red', 'EU 34', 250.00, 25, 0);
