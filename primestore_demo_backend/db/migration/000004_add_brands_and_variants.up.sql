CREATE TABLE brands (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    logo_url VARCHAR(500),
    is_verified BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE products
    ALTER COLUMN seller_id DROP NOT NULL,
    ADD COLUMN brand_id INT REFERENCES brands(id) ON DELETE SET NULL,
    ADD COLUMN is_featured BOOLEAN NOT NULL DEFAULT false;

ALTER TABLE products DROP COLUMN price;
ALTER TABLE products DROP COLUMN stock_qty;
ALTER TABLE products DROP COLUMN image_url;

CREATE TABLE product_images (
    id SERIAL PRIMARY KEY,
    product_id INT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    image_url VARCHAR(500) NOT NULL,
    sort_order INT NOT NULL DEFAULT 0
);

CREATE TABLE product_variants (
    id SERIAL PRIMARY KEY,
    product_id INT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    color VARCHAR(50),
    size VARCHAR(20),
    price NUMERIC(10, 2) NOT NULL,
    discount_percent INT NOT NULL DEFAULT 0,
    stock INT NOT NULL DEFAULT 0,
    UNIQUE(product_id, color, size)
);
