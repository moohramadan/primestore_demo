-- IsProductImageReferenced looks images up by image_url; without an index
-- that is a full table scan every time a seller removes a photo.
CREATE INDEX IF NOT EXISTS idx_product_images_image_url
    ON product_images (image_url);
