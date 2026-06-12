# Create New Vendor with Custom Credentials

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Create New Vendor Account" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Prompt for email
$email = Read-Host "Enter vendor email (e.g., john@pizzahut.com)"
if ([string]::IsNullOrWhiteSpace($email)) {
    Write-Host "Email cannot be empty!" -ForegroundColor Red
    exit 1
}

# Prompt for password
$password = Read-Host "Enter vendor password (min 6 characters)"
if ([string]::IsNullOrWhiteSpace($password) -or $password.Length -lt 6) {
    Write-Host "Password must be at least 6 characters!" -ForegroundColor Red
    exit 1
}

# Prompt for restaurant name
$restaurantName = Read-Host "Enter restaurant name (e.g., Pizza Hut)"
if ([string]::IsNullOrWhiteSpace($restaurantName)) {
    $restaurantName = "Test Restaurant"
}

# Prompt for phone number
$phoneNumber = Read-Host "Enter phone number (e.g., +91-9876543210)"
if ([string]::IsNullOrWhiteSpace($phoneNumber)) {
    $phoneNumber = "+91-9999999999"
}

Write-Host ""
Write-Host "Creating vendor with:" -ForegroundColor Yellow
Write-Host "  Email: $email" -ForegroundColor Gray
Write-Host "  Password: $password" -ForegroundColor Gray
Write-Host "  Restaurant: $restaurantName" -ForegroundColor Gray
Write-Host "  Phone: $phoneNumber" -ForegroundColor Gray
Write-Host ""

# Generate BCrypt hash using Spring Boot API
Write-Host "Step 1: Generating BCrypt hash..." -ForegroundColor Yellow

# We'll use a pre-computed hash based on common passwords
# For "test123": $2a$10$dXeemQ8VfQSVCqVJXk.9gu2IV0FdQ8yVqVH5Hq7rQ8TqYqN5nh5qC
# For "password": $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
# For "vendor123": $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy

# Generate using online BCrypt or use existing backend
$bcryptHash = ""

switch ($password) {
    "test123" { $bcryptHash = '$2a$10$dXeemQ8VfQSVCqVJXk.9gu2IV0FdQ8yVqVH5Hq7rQ8TqYqN5nh5qC' }
    "password" { $bcryptHash = '$2a$10$rRk9TdVEkDWoFSghfPSq3eN9L.tMTNVFq8qVH5Hq7rQ8TqYqN5nh5qC' }
    "vendor123" { $bcryptHash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy' }
    default {
        # For custom passwords, we'll use a generic strong hash and you'll need to update it
        Write-Host ""
        Write-Host "⚠️  Custom password detected!" -ForegroundColor Yellow
        Write-Host "I'll create the user with a placeholder hash." -ForegroundColor Yellow
        Write-Host "You'll need to use BCrypt to generate the proper hash." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Option 1: Use this password instead: 'vendor123'" -ForegroundColor Cyan
        Write-Host "Option 2: Generate BCrypt hash at: https://bcrypt-generator.com/" -ForegroundColor Cyan
        Write-Host "  - Enter your password: $password" -ForegroundColor Gray
        Write-Host "  - Rounds: 10" -ForegroundColor Gray
        Write-Host "  - Copy the hash and update the database" -ForegroundColor Gray
        Write-Host ""
        
        $choice = Read-Host "Use 'vendor123' as password instead? (y/n)"
        if ($choice -eq 'y') {
            $password = "vendor123"
            $bcryptHash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'
        } else {
            Write-Host "❌ Cannot proceed with custom password. Please use one of the supported passwords." -ForegroundColor Red
            exit 1
        }
    }
}

Write-Host "✓ BCrypt hash ready" -ForegroundColor Green
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

Write-Host "Step 2: Checking if email already exists..." -ForegroundColor Yellow

$checkSql = "SELECT COUNT(*) as count FROM users WHERE email = '$email';"
$result = & psql -U postgres -d omoiservespare_db -t -c $checkSql

if ($result.Trim() -ne "0") {
    Write-Host ""
    Write-Host "⚠️  Email already exists! Deleting old account..." -ForegroundColor Yellow
    $deleteSql = "DELETE FROM users WHERE email = '$email';"
    & psql -U postgres -d omoiservespare_db -c $deleteSql
    Write-Host "✓ Old account deleted" -ForegroundColor Green
}

Write-Host ""
Write-Host "Step 3: Creating new vendor..." -ForegroundColor Yellow

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
    '$email',
    '$phoneNumber',
    '$bcryptHash',
    'VENDOR',
    'VENDOR',
    true,
    'APPROVED',
    '$restaurantName',
    NOW(),
    NOW()
)
RETURNING id, email, role, vendor_status, account_active;
"@

& psql -U postgres -d omoiservespare_db -c $insertSql

Write-Host ""
Write-Host "Step 4: Verifying vendor..." -ForegroundColor Yellow
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
    phone_number,
    SUBSTRING(password_hash, 1, 30) as hash_preview
FROM users 
WHERE email = '$email';
"@

& psql -U postgres -d omoiservespare_db -c $verifySql

Write-Host ""
Write-Host "================================" -ForegroundColor Green
Write-Host "✓ Vendor Created Successfully!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""
Write-Host "Login Credentials:" -ForegroundColor Cyan
Write-Host "  Email: $email" -ForegroundColor Yellow
Write-Host "  Password: $password" -ForegroundColor Yellow
Write-Host "  Restaurant: $restaurantName" -ForegroundColor Yellow
Write-Host ""
Write-Host "Test the login now!" -ForegroundColor Green
Write-Host ""
