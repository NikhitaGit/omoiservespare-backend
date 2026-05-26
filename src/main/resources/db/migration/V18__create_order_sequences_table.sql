-- Create order sequences table for payment method-based order codes
CREATE TABLE order_sequences (
    payment_method VARCHAR(20) PRIMARY KEY,
    current_sequence BIGINT NOT NULL DEFAULT 0,
    version BIGINT DEFAULT 0
);

-- Insert initial sequences for each payment method
INSERT INTO order_sequences (payment_method, current_sequence, version) VALUES 
('ONLINE', 0, 0),
('WALLET', 0, 0),
('CASH', 0, 0);

-- Create index for better performance
CREATE INDEX idx_order_sequences_payment_method ON order_sequences(payment_method);