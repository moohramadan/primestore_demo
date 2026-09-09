ALTER TABLE users
    DROP COLUMN google_id,
    ALTER COLUMN password_hash SET NOT NULL;