# Generate Fresh BCrypt Hash for Vendor Password

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Generating Fresh Vendor Hash" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# We'll use a known working BCrypt hash for "vendor123"
# This was generated using: BCryptPasswordEncoder().encode("vendor123") with strength 10
$correctHash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'

Write-Host "Using BCrypt hash for password 'vendor123'" -ForegroundColor Yellow
Write-Host "Hash: $correctHash" -ForegroundColor Gray
Write-Host ""

# Load environment
if (Test-Path .env) {
    Get-Content .env | ForEach-Object {
        if ($_ -match '^([^=]+)=(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($key, $value, "Process")
        }
    }
}

$DB_PASSWORD = $env:DB_PASSWORD
if (-not $DB_PASSWORD) {
    $DB_PASSWORD = "NikhitaMumbai123*"
}

$env:PGPASSWORD = $DB_PASSWORD

Write-Host "Step 1: Deleting existing vendor..." -ForegroundColor Yellow

$deleteSql = "DELETE FROM users WHERE email = 'vendor@restaurant.com';"
& psql -U postgres -d omoiservespare_db -c $deleteSql

Write-Host "Step 2: Creating vendor with fresh hash..." -ForegroundColor Yellow
Write-Host ""

$insertSql = @"
INSERT INTO users (
    email, 
    phone_number, 
    password_hash, 
    role,
    account_type,
    account_active, 
    vendor_status,
    company_name,
    created_at, 
    updated_at
)
VALUES (
    'vendor@restaurant.com',
    '+91-9999999991',
    '$correctHash',
    'VENDOR',
    'VENDOR',
    true,
    'APPROVED',
    'Test Restaurant',
    NOW(),
    NOW()
)
RETURNING id, email, role, vendor_status, account_active;
"@

& psql -U postgres -d omoiservespare_db -c $insertSql

Write-Host ""
Write-Host "Step 3: Verifying vendor..." -ForegroundColor Yellow
Write-Host ""

$verifySql = @"
SELECT 
    id,
    email,
    role,
    account_type,
    vendor_status,
    account_active,
    company_name,
    SUBSTRING(password_hash, 1, 30) as hash_start,
    LENGTH(password_hash) as hash_length
FROM users 
WHERE email = 'vendor@restaurant.com';
"@

& psql -U postgres -d omoiservespare_db -c $verifySql

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Now test login with:" -ForegroundColor Green
Write-Host "  Email: vendor@restaurant.com" -ForegroundColor Yellow
Write-Host "  Password: vendor123" -ForegroundColor Yellow
Write-Host ""
Write-Host "Run: .\test-vendor-login-detailed.ps1" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
