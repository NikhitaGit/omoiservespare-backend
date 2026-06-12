-- 📍 Add detailed address components to user_addresses table
-- Production-grade location system with area, city, state, country, postal_code
-- Similar to Swiggy/Zomato detailed address breakdown

-- Add detailed address component columns
ALTER TABLE user_addresses
ADD COLUMN IF NOT EXISTS area VARCHAR(255),
ADD COLUMN IF NOT EXISTS city VARCHAR(100),
ADD COLUMN IF NOT EXISTS state VARCHAR(100),
ADD COLUMN IF NOT EXISTS country VARCHAR(100),
ADD COLUMN IF NOT EXISTS postal_code VARCHAR(20);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_user_addresses_city ON user_addresses(city);
CREATE INDEX IF NOT EXISTS idx_user_addresses_state ON user_addresses(state);
CREATE INDEX IF NOT EXISTS idx_user_addresses_postal_code ON user_addresses(postal_code);

-- Add comment for documentation
COMMENT ON COLUMN user_addresses.area IS 'Locality/Neighborhood (e.g., Andheri West, Koramangala)';
COMMENT ON COLUMN user_addresses.city IS 'City/Town name (e.g., Mumbai, Bangalore)';
COMMENT ON COLUMN user_addresses.state IS 'State/Province name (e.g., Maharashtra, Karnataka)';
COMMENT ON COLUMN user_addresses.country IS 'Country name (e.g., India)';
COMMENT ON COLUMN user_addresses.postal_code IS 'Postal/PIN/ZIP code (e.g., 400053)';

-- Note: Existing addresses will have NULL values for these new columns
-- They will be populated when users update their addresses or use current location feature
