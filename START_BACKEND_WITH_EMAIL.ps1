# Complete Backend Startup with Email Support
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Backend Startup with Email" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

Write-Host "`nStep 1: Checking Vault..." -ForegroundColor Yellow

$vaultRunning = $false
try {
    $vaultCheck = curl -s http://localhost:8200/v1/sys/health 2>&1
    if ($LASTEXITCODE -eq 0) {
        $vaultRunning = $true
        Write-Host "✓ Vault is already running" -ForegroundColor Green
    }
} catch {
    Write-Host "  Vault not running" -ForegroundColor Gray
}

if (-not $vaultRunning) {
    Write-Host "  Starting Vault..." -ForegroundColor Yellow
    Start-Process -FilePath "vault" -ArgumentList "server -dev -dev-root-token-id=myroot" -WindowStyle Normal
    Start-Sleep -Seconds 3
    Write-Host "✓ Vault started" -ForegroundColor Green
}

Write-Host "`nStep 2: Configuring Email in Vault..." -ForegroundColor Yellow

$emailConfig = @{
    "mail.username" = "akshaykabbur8@gmail.com"
    "mail.password" = "ahacuztuboepqydt"
    "mail.from" = "akshaykabbur8@gmail.com"
}

$jsonPayload = @{
    data = $emailConfig
} | ConvertTo-Json -Compress

curl -X POST -H "X-Vault-Token: myroot" -H "Content-Type: application/json" `
    -d $jsonPayload `
    http://localhost:8200/v1/secret/data/OmoiServespare 2>&1 | Out-Null

Write-Host "✓ Email configuration updated in Vault" -ForegroundColor Green

Write-Host "`nStep 3: Starting Backend Application..." -ForegroundColor Yellow
Write-Host "  (This may take 30-60 seconds)" -ForegroundColor Gray

mvn spring-boot:run

Write-Host "`n==================================" -ForegroundColor Cyan
Write-Host "Backend Stopped" -ForegroundColor Yellow
Write-Host "==================================" -ForegroundColor Cyan
