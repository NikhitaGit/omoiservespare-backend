# 🔧 Fix Port 8080 - Kill Existing Process
# This script finds and kills the process using port 8080

Write-Host "`n🔧 Fixing Port 8080 Issue..." -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

# Find process using port 8080
Write-Host "🔍 Searching for process using port 8080..." -ForegroundColor Yellow

$processInfo = netstat -ano | findstr :8080 | findstr LISTENING

if ($processInfo) {
    Write-Host "✅ Found process using port 8080:" -ForegroundColor Green
    Write-Host $processInfo -ForegroundColor White
    
    # Extract PID (last column)
    $pid = ($processInfo -split '\s+')[-1]
    
    Write-Host "`n📋 Process ID (PID): $pid" -ForegroundColor Cyan
    
    # Get process details
    try {
        $process = Get-Process -Id $pid -ErrorAction Stop
        Write-Host "📦 Process Name: $($process.ProcessName)" -ForegroundColor Cyan
        Write-Host "💾 Memory Usage: $([math]::Round($process.WorkingSet64 / 1MB, 2)) MB" -ForegroundColor Cyan
        
        # Confirm before killing
        Write-Host "`n⚠️  This will terminate the process." -ForegroundColor Yellow
        $confirm = Read-Host "Do you want to kill this process? (y/n)"
        
        if ($confirm -eq "y") {
            Write-Host "`n🔪 Killing process $pid..." -ForegroundColor Yellow
            Stop-Process -Id $pid -Force
            Start-Sleep -Seconds 2
            
            # Verify port is free
            $checkAgain = netstat -ano | findstr :8080 | findstr LISTENING
            if ($checkAgain) {
                Write-Host "❌ Port 8080 is still in use. Trying force kill..." -ForegroundColor Red
                taskkill /F /PID $pid
                Start-Sleep -Seconds 2
            }
            
            Write-Host "✅ Process killed successfully!" -ForegroundColor Green
            Write-Host "✅ Port 8080 is now free" -ForegroundColor Green
            
            Write-Host "`n📝 Next Steps:" -ForegroundColor Yellow
            Write-Host "1. Run: mvn spring-boot:run" -ForegroundColor White
            Write-Host "2. Or run: .\setup-google-maps-api.ps1" -ForegroundColor White
            
        } else {
            Write-Host "`n❌ Operation cancelled" -ForegroundColor Red
            Write-Host "   Port 8080 is still in use" -ForegroundColor Yellow
        }
        
    } catch {
        Write-Host "❌ Could not get process details" -ForegroundColor Red
        Write-Host "   Trying to kill PID $pid anyway..." -ForegroundColor Yellow
        
        try {
            taskkill /F /PID $pid
            Write-Host "✅ Process killed" -ForegroundColor Green
        } catch {
            Write-Host "❌ Failed to kill process" -ForegroundColor Red
            Write-Host "   You may need to run PowerShell as Administrator" -ForegroundColor Yellow
        }
    }
    
} else {
    Write-Host "✅ Port 8080 is free!" -ForegroundColor Green
    Write-Host "   No process is using port 8080" -ForegroundColor Cyan
    
    Write-Host "`n📝 You can now start the application:" -ForegroundColor Yellow
    Write-Host "   mvn spring-boot:run" -ForegroundColor White
}

Write-Host "`n✅ Done!" -ForegroundColor Cyan
