-- Create Test Orders for Admin Dashboard
-- Run this in your PostgreSQL database to populate test data

-- Note: Replace user_id and canteen_id with actual IDs from your database

-- First, check what users and canteens exist
SELECT id, email FROM users LIMIT 5;
SELECT id, name FROM canteens LIMIT 5;
SELECT id, name, price FROM menu_items LIMIT 10;

-- Create test orders (adjust IDs based on your data)
-- Example: Assuming user_id=1, canteen_id=1

-- Order 1: Today - Breakfast order
INSERT INTO orders (user_id, canteen_id, total_amount, status, created_at, updated_at)
VALUES (1, 1, 150.00, 'PAID', NOW(), NOW())
RETURNING id;

-- Get the order_id from above and use it here
-- Replace <order_id> with the actual ID returned

-- Add items to Order 1
INSERT INTO order_items (order_id, item_id, quantity, price)
VALUES 
    (<order_id>, 1, 2, 30.00),  -- 2 Idli
    (<order_id>, 2, 2, 15.00);  -- 2 Tea

-- Order 2: Today - Lunch order
INSERT INTO orders (user_id, canteen_id, total_amount, status, created_at, updated_at)
VALUES (1, 1, 250.00, 'PAID', NOW(), NOW())
RETURNING id;

-- Add items to Order 2
INSERT INTO order_items (order_id, item_id, quantity, price)
VALUES 
    (<order_id>, 3, 1, 120.00),  -- 1 Veg Thali
    (<order_id>, 4, 1, 60.00),   -- 1 Dosa
    (<order_id>, 5, 1, 25.00);   -- 1 Coffee

-- Order 3: Yesterday
INSERT INTO orders (user_id, canteen_id, total_amount, status, created_at, updated_at)
VALUES (1, 1, 180.00, 'PAID', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day')
RETURNING id;

-- Add items to Order 3
INSERT INTO order_items (order_id, item_id, quantity, price)
VALUES 
    (<order_id>, 1, 3, 30.00),  -- 3 Idli
    (<order_id>, 2, 3, 15.00);  -- 3 Tea

-- Order 4: Last week
INSERT INTO orders (user_id, canteen_id, total_amount, status, created_at, updated_at)
VALUES (1, 1, 320.00, 'PAID', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days')
RETURNING id;

-- Add items to Order 4
INSERT INTO order_items (order_id, item_id, quantity, price)
VALUES 
    (<order_id>, 3, 2, 120.00),  -- 2 Veg Thali
    (<order_id>, 5, 2, 25.00);   -- 2 Coffee

-- Verify orders were created
SELECT 
    o.id,
    o.status,
    o.total_amount,
    o.created_at,
    COUNT(oi.id) as item_count
FROM orders o
LEFT JOIN order_items oi ON o.id = oi.order_id
WHERE o.status = 'PAID'
GROUP BY o.id, o.status, o.total_amount, o.created_at
ORDER BY o.created_at DESC;
