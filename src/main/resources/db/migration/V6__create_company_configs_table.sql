-- Create company_configs table for multi-company support
CREATE TABLE IF NOT EXISTS company_configs (
    id BIGSERIAL PRIMARY KEY,
    company_name VARCHAR(255) UNIQUE NOT NULL,
    company_code VARCHAR(50) UNIQUE NOT NULL,
    
    -- HR API Configuration
    hr_api_enabled BOOLEAN DEFAULT true,
    hr_api_base_url VARCHAR(500) NOT NULL,
    hr_api_token VARCHAR(500) NOT NULL,
    hr_api_timeout INTEGER DEFAULT 30000,
    
    -- Company Settings
    is_active BOOLEAN DEFAULT true,
    max_employees INTEGER,
    subscription_tier VARCHAR(50),
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255),
    
    -- Additional Settings (JSON for flexibility)
    additional_settings JSONB
);

-- Indexes for fast lookup
CREATE INDEX idx_company_configs_name ON company_configs(company_name);
CREATE INDEX idx_company_configs_code ON company_configs(company_code);
CREATE INDEX idx_company_configs_active ON company_configs(is_active);

-- Insert default companies for testing
INSERT INTO company_configs (
    company_name, 
    company_code, 
    hr_api_enabled, 
    hr_api_base_url, 
    hr_api_token,
    is_active,
    subscription_tier
) VALUES 
(
    'Omoiservespare Pvt Ltd',
    'OMOI',
    false,  -- Use mock data for now
    'https://omoiservespare-hr.com/api/v1',
    'omoi-demo-token-123',
    true,
    'ENTERPRISE'
),
(
    'Omoikane Innovations',
    'OMIK',
    false,  -- Use mock data for now
    'https://omoikane-hr.com/api/v1',
    'omik-demo-token-456',
    true,
    'PROFESSIONAL'
),
(
    'Tech Corp',
    'TECH',
    false,  -- Use mock data for now
    'https://techcorp-hr-api.com/v2',
    'tech-demo-token-789',
    true,
    'PROFESSIONAL'
),
(
    'Innovation Labs',
    'INNO',
    false,  -- Use mock data for now
    'https://innovation-labs.com/hr/api',
    'inno-demo-token-012',
    true,
    'STARTER'
);

-- Add comment
COMMENT ON TABLE company_configs IS 'Stores configuration for multiple companies including HR API settings';
