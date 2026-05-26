-- Create invoices table for production-grade invoice system
CREATE TABLE invoices (
    id BIGSERIAL PRIMARY KEY,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    invoice_type VARCHAR(20) NOT NULL,
    
    order_id BIGINT REFERENCES orders(id),
    canteen_order_id BIGINT REFERENCES canteen_orders(id),
    canteen_id BIGINT,
    customer_id BIGINT REFERENCES users(id),
    
    subtotal DECIMAL(10,2) NOT NULL,
    cgst DECIMAL(10,2) NOT NULL,
    sgst DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    
    invoice_date TIMESTAMP NOT NULL,
    payment_status VARCHAR(20) DEFAULT 'PENDING',
    
    from_name VARCHAR(255),
    to_name VARCHAR(255),
    
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX idx_invoice_order ON invoices(order_id);
CREATE INDEX idx_invoice_canteen_order ON invoices(canteen_order_id);
CREATE INDEX idx_invoice_customer ON invoices(customer_id);
CREATE INDEX idx_invoice_number_prefix ON invoices(invoice_number);