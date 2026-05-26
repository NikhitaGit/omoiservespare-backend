-- Check if vendor user exists
SELECT id, email, role, vendor_status, password 
FROM users 
WHERE email = 'vendor@restaurant.com';

-- Check all vendors
SELECT id, email, role, vendor_status 
FROM users 
WHERE role = 'VENDOR';
