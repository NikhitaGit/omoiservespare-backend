-- Fix Payment Status for Admin Dashboard
-- The dashboard uses payment_status = 'SUCCESS', not status = 'PAID'

-- Step 1: Check current payment statuses
SELECT 
    status,
    payment_status,
    COUNT(*) as count,
    SUM(total_amount) as revenue
FROM orders 
GROUP BY status, payment_status;

-- Step 2: Update payment_status to SUCCESS
UPDATE orders 
SET payment_status = 'SUCCESS',
    updated_at = NOW()
WHERE payment_status IS NULL 
   OR payment_status = 'PENDING'
   OR payment_status = 'FAILED';

-- Step 3: Verify the update
SELECT 
    status,
    payment_status,
    COUNT(*) as count,
    SUM(total_amount) as revenue
FROM orders 
GROUP BY status, payment_status;

-- Step 4: Check what dashboard will see
SELECT 
    COUNT(*) as total_orders,
    SUM(total_amount) as total_revenue,
    COUNT(DISTINCT customer_id) as unique_customers
FROM orders 
WHERE payment_status = 'SUCCESS';

-- Step 5: Check orders by date
SELECT 
    DATE(created_at) as order_date,
    COUNT(*) as orders,
    SUM(total_amount) as revenue
FROM orders 
WHERE payment_status = 'SUCCESS'
GROUP BY DATE(created_at)
ORDER BY order_date DESC;

-- Done! Now refresh your admin dashboard
