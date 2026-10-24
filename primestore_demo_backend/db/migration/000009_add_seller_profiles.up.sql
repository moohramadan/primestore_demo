CREATE TABLE seller_profiles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    account_type VARCHAR(20) NOT NULL
        CHECK (account_type IN ('individual', 'private_business', 'public_business', 'non_profit')),
    business_name VARCHAR(150) NOT NULL,
    business_phone VARCHAR(20) NOT NULL,
    business_address TEXT NOT NULL,
    verification_status VARCHAR(20) NOT NULL DEFAULT 'unverified'
        CHECK (verification_status IN ('unverified', 'pending', 'verified', 'rejected')),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE seller_payout_accounts (
    id SERIAL PRIMARY KEY,
    seller_id INTEGER NOT NULL UNIQUE REFERENCES seller_profiles(id) ON DELETE CASCADE,
    account_holder_name VARCHAR(150) NOT NULL,
    bank_name VARCHAR(100) NOT NULL,
    account_number VARCHAR(30) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);