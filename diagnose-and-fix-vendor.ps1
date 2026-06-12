# Diagnose and Fix Vendor Login Issue

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Vendor Login Diagnostic & Fix" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Load environment variables
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

Write-Host "Step 1: Checking current vendor accounts..." -ForegroundColor Yellow
Write-Host ""

$checkSql = @"
SELECT 
    id,
    email,
    role,
    account_type,
    vendor_status,
    account_active,
    SUBSTRING(password_hash, 1, 30) as hash_preview,
    LENGTH(password_hash) as hash_length
FROM users 
WHERE role = 'VENDOR' OR email LIKE '%vendor%'
ORDER BY created_at DESC;
"@

& psql -U postgres -d omoiservespare_db -c $checkSql

Write-Host ""
Write-Host "Step 2: Creating/Updating vendor account..." -ForegroundColor Yellow
Write-Host ""

$fixSql = @"
-- Delete existing vendor
DELETE FROM users WHERE email = 'vendor@restaurant.com';

-- Insert vendor with correct BCrypt hash for 'vendor123'
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
    '\$2a\$10\$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
    'VENDOR',
    'VENDOR',
    true,
    'APPROVED',
    'Test Restaurant',
    NOW(),
    NOW()
);

-- Verify insertion
SELECT 
    id,
    email,
    role,
    account_type,
    vendor_status,
    account_active,
    SUBSTRING(password_hash, 1, 30) as hash_preview
FROM users 
WHERE email = 'vendor@restaurant.com';
"@

& psql -U postgres -d omoiservespare_db -c $fixSql

Write-Host ""
Write-Host "Step 3: Testing vendor login..." -ForegroundColor Yellow
Write-Host ""

$loginBody = @{
    email = "vendor@restaurant.com"
    password = "vendor123"
} | ConvertTo-Json

$deviceId = [guid]::NewGuid().ToString()

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/vendor/login" `
        -Method POST `
        -Body $loginBody `
        -ContentType "application/json" `
        -Headers @{
            "X-Device-ID" = $deviceId
            "X-Device-Name" = "PowerShell Test"
        }
    
    Write-Host "✓ Login successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Response:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 5
    
} catch {
    Write-Host "✗ Login failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error:" -ForegroundColor Red
    Write-Host $_.Exception.Message
    
    if ($_.ErrorDetails.Message) {
        Write-Host ""
        Write-Host "Details:" -ForegroundColor Red
        Write-Host $_.ErrorDetails.Message
    }
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Credentials to use:" -ForegroundColor Cyan
Write-Host "  Email: vendor@restaurant.com" -ForegroundColor Yellow
Write-Host "  Password: vendor123" -ForegroundColor Yellow
Write-Host "================================" -ForegroundColor Cyan
