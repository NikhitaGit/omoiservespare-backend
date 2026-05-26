-- =====================================================
-- V11: Create Vendors Table (PostgreSQL)
-- =====================================================
-- Purpose: Store vendor-specific details (restaurant info)
-- Linked to users table via user_id

CREATE TABLE IF NOT EXISTS vendors (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    restaurant_name VARCHAR(255) NOT NULL,
    owner_name VARCHAR(255) NOT NULL,
    address TEXT,
    business_license VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_vendor_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Index for faster lookups
CREATE INDEX IF NOT EXISTS idx_vendor_user_id ON vendors(user_id);

-- Trigger for updated_at timestamp (PostgreSQL doesn't support ON UPDATE)
DROP TRIGGER IF EXISTS vendors_updated_at_trigger ON vendors;

CREATE OR REPLACE FUNCTION update_vendors_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER vendors_updated_at_trigger
BEFORE UPDATE ON vendors
FOR EACH ROW
EXECUTE FUNCTION update_vendors_updated_at();

-- =====================================================
-- Comments
-- =====================================================
-- This table stores vendor-specific information
-- When a vendor registers, a User record is created with role=VENDOR
-- and vendor_status=PENDING, then this table stores the restaurant details
