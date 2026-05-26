-- Create feedback table for company feedback system
CREATE TABLE feedback (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comments TEXT NOT NULL CHECK (LENGTH(comments) <= 2000 AND LENGTH(comments) > 0),
    status VARCHAR(20) NOT NULL DEFAULT 'NEW',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP,
    
    CONSTRAINT fk_feedback_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT chk_status CHECK (status IN ('NEW', 'REVIEWED'))
);

-- Create indexes for performance optimization
CREATE INDEX idx_feedback_company ON feedback(company_name);
CREATE INDEX idx_feedback_status ON feedback(status);
CREATE INDEX idx_feedback_created_at ON feedback(created_at DESC);
CREATE INDEX idx_feedback_company_status ON feedback(company_name, status);

-- Add comment for documentation
COMMENT ON TABLE feedback IS 'Stores user feedback submissions with ratings and comments for multi-tenant company feedback system';
COMMENT ON COLUMN feedback.rating IS 'User satisfaction rating from 1 (lowest) to 5 (highest)';
COMMENT ON COLUMN feedback.status IS 'Feedback status: NEW (unreviewed) or REVIEWED (admin has reviewed)';
COMMENT ON COLUMN feedback.company_name IS 'Company identifier for multi-tenant data isolation';
