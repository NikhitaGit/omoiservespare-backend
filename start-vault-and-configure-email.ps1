# Start HashiCorp Vault and Configure Email Settings
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Starting Vault & Configuring Email" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

Write-Host "`nStep 1: Starting Vault in Dev Mode..." -ForegroundColor Yellow

# Start Vault in dev mode (new window)
$vaultProcess = Start-Process -FilePath "vault" -ArgumentList "server -dev -dev-root-token-id=myroot" -PassThru -WindowStyle Normal

Write-Host "✓ Vault server started (Process ID: $($vaultProcess.Id))" -ForegroundColor Green
Write-Host "  Vault UI: http://localhost:8200" -ForegroundColor White
Write-Host "  Root Token: myroot" -ForegroundColor White

Start-Sleep -Seconds 3

Write-Host "`nStep 2: Configuring Vault environment..." -ForegroundColor Yellow

$env:VAULT_ADDR="http://localhost:8200"
$env:VAULT_TOKEN="myroot"

Write-Host "✓ Environment configured" -ForegroundColor Green

Write-Host "`nStep 3: Storing Email Configuration in Vault..." -ForegroundColor Yellow

# Store email credentials in Vault
$emailConfig = @{
    "mail.username" = "akshaykabbur8@gmail.com"
    "mail.password" = "ahacuztuboepqydt"
    "mail.from" = "akshaykabbur8@gmail.com"
}

$jsonData = $emailConfig | ConvertTo-Json -Compress

# Use curl to store in Vault
curl -X POST -H "X-Vault-Token: myroot" -H "Content-Type: application/json" `
    -d "{`"data`":$jsonData}" `
    http://localhost:8200/v1/secret/data/OmoiServespare

Write-Host "`n✓ Email configuration stored in Vault" -ForegroundColor Green

Write-Host "`nStep 4: Verifying stored data..." -ForegroundColor Yellow

$response = curl -H "X-Vault-Token: myroot" http://localhost:8200/v1/secret/data/OmoiServespare
Write-Host $response -ForegroundColor White

Write-Host "`n==================================" -ForegroundColor Cyan
Write-Host "✅ Vault Configuration Complete!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan

Write-Host "`nVault is now running with email configuration." -ForegroundColor White
Write-Host "You can now start your backend application." -ForegroundColor White
Write-Host "`nTo stop Vault later:" -ForegroundColor Yellow
Write-Host "  Find the process and close its window" -ForegroundColor White
Write-Host "`nNext step: Run your backend with 'mvn spring-boot:run'" -ForegroundColor Cyan
