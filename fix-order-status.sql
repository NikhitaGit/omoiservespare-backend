-- Fix Order Status - Update ORDER_RECEIVED to PAID
-- Run this in PostgreSQL to make orders visible in admin dashboard

-- Step 1: Check current status
SELECT 
    status, 
    COUNT(*) as count,
    SUM(total_amount) as revenue
FROM orders 
GROUP BY status;

-- Step 2: Update ORDER_RECEIVED to PAID
UPDATE orders 
SET status = 'PAID',
    updated_at = NOW()
WHERE status = 'ORDER_RECEIVED';

-- Step 3: Verify the update
SELECT 
    status, 
    COUNT(*) as count,
    SUM(total_amount) as revenue
FROM orders 
GROUP BY status;

-- Step 4: Check dashboard data
SELECT 
    COUNT(*) as total_paid_orders,
    SUM(total_amount) as total_revenue,
    COUNT(DISTINCT user_id) as unique_customers
FROM orders 
WHERE status = 'PAID';

-- Step 5: Check today's orders
SELECT 
    COUNT(*) as today_orders,
    SUM(total_amount) as today_revenue
FROM orders 
WHERE status = 'PAID' 
AND DATE(created_at) = CURRENT_DATE;

-- Step 6: Check trending items
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

-- Done! Now refresh your admin dashboard
