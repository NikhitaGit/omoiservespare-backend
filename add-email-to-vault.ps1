# Add Email Configuration to Running Vault
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Adding Email Config to Vault" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

Write-Host "`nChecking if Vault is running..." -ForegroundColor Yellow

$vaultCheck = curl -s http://localhost:8200/v1/sys/health 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ ERROR: Vault is not running!" -ForegroundColor Red
    Write-Host "`nPlease start Vault first with:" -ForegroundColor Yellow
    Write-Host "  .\start-vault-and-configure-email.ps1" -ForegroundColor White
    exit 1
}

Write-Host "✓ Vault is running" -ForegroundColor Green

Write-Host "`nAdding email credentials to Vault..." -ForegroundColor Yellow

# Read existing vault data first
Write-Host "  Reading existing Vault data..." -ForegroundColor Gray
$existingData = curl -H "X-Vault-Token: myroot" http://localhost:8200/v1/secret/data/OmoiServespare 2>$null

# Store email credentials
$emailConfig = @{
    "mail.username" = "akshaykabbur8@gmail.com"
    "mail.password" = "ahacuztuboepqydt"
    "mail.from" = "akshaykabbur8@gmail.com"
}

Write-Host "  Storing email configuration..." -ForegroundColor Gray

# Create JSON payload
$jsonPayload = @{
    data = $emailConfig
} | ConvertTo-Json -Compress

# Store in Vault
$response = curl -X POST `
    -H "X-Vault-Token: myroot" `
    -H "Content-Type: application/json" `
    -d $jsonPayload `
    http://localhost:8200/v1/secret/data/OmoiServespare

Write-Host "`n✓ Email credentials added to Vault" -ForegroundColor Green

Write-Host "`nVerifying..." -ForegroundColor Yellow
$verify = curl -H "X-Vault-Token: myroot" http://localhost:8200/v1/secret/data/OmoiServespare

Write-Host $verify -ForegroundColor White

Write-Host "`n==================================" -ForegroundColor Cyan
Write-Host "✅ Email Configuration Added!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan

Write-Host "`nVault now contains:" -ForegroundColor White
Write-Host "  ✓ mail.username = akshaykabbur8@gmail.com" -ForegroundColor Green
Write-Host "  ✓ mail.password = ahacuztuboepqydt" -ForegroundColor Green
Write-Host "  ✓ mail.from = akshaykabbur8@gmail.com" -ForegroundColor Green

Write-Host "`nYour backend can now read email config from Vault!" -ForegroundColor Cyan
