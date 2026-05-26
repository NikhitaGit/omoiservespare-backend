-- Check Database Orders for Admin Dashboard
-- Run this in your PostgreSQL database

-- 1. Check if orders table exists
SELECT COUNT(*) as total_orders FROM orders;

-- 2. Check order statuses
SELECT status, COUNT(*) as count 
FROM orders 
GROUP BY status;

-- 3. Check PAID orders (what dashboard uses)
SELECT COUNT(*) as paid_orders 
FROM orders 
WHERE status = 'PAID';

-- 4. Check total revenue from PAID orders
SELECT 
    COUNT(*) as paid_orders,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as avg_order_value
FROM orders 
WHERE status = 'PAID';

-- 5. Check orders by date
SELECT 
    DATE(created_at) as order_date,
    COUNT(*) as orders,
    SUM(total_amount) as revenue
FROM orders 
WHERE status = 'PAID'
GROUP BY DATE(created_at)
ORDER BY order_date DESC
LIMIT 10;

-- 6. Check order items (for trending items)
SELECT 
    mi.name as item_name,
    SUM(oi.quantity) as total_quantity,
    SUM(oi.quantity * oi.price) as total_revenue
FROM order_items oi
JOIN menu_items mi ON oi.item_id = mi.id
JOIN orders o ON oi.order_id = o.id
WHERE o.status = 'PAID'
GROUP BY mi.name
ORDER BY total_quantity DESC
LIMIT 10;

-- 7. Check if there are ANY orders (regardless of status)
SELECT 
    id,
    status,
    total_amount,
    created_at,
    user_id
FROM orders
ORDER BY created_at DESC
LIMIT 5;
