# Diagnose Startup Errors
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Application Startup Diagnostics" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check Services
Write-Host "[Step 1/5] Checking Services..." -ForegroundColor Yellow
Write-Host ""

# PostgreSQL
Write-Host "  PostgreSQL:" -ForegroundColor White
try {
    $env:PGPASSWORD = "NikhitaMumbai123*"
    $pgResult = & "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d omoiservespare_db -c "SELECT 1;" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "    ✅ Running and accessible" -ForegroundColor Green
    } else {
        Write-Host "    ❌ PROBLEM DETECTED" -ForegroundColor Red
        Write-Host "    Error: $pgResult" -ForegroundColor Red
        Write-Host ""
        Write-Host "    Fix: Check TROUBLESHOOTING.md - Error 2" -ForegroundColor Yellow
    }
} catch {
    Write-Host "    ❌ PROBLEM DETECTED" -ForegroundColor Red
    Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Redis
Write-Host "  Redis:" -ForegroundColor White
try {
    $dockerCheck = docker ps 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "    ❌ Docker not running" -ForegroundColor Red
        Write-Host "    Fix: Start Docker Desktop" -ForegroundColor Yellow
    } else {
        $redisCheck = docker ps --filter "name=redis" --format "{{.Names}}" 2>&1
        if ($redisCheck -match "redis") {
            $redisPing = docker exec redis redis-cli ping 2>&1
            if ($redisPing -match "PONG") {
                Write-Host "    ✅ Running and responding" -ForegroundColor Green
            } else {
                Write-Host "    ⚠️  Container exists but not responding" -ForegroundColor Yellow
                Write-Host "    Fix: docker restart redis" -ForegroundColor Yellow
            }
        } else {
            Write-Host "    ❌ Redis container not found" -ForegroundColor Red
            Write-Host "    Fix: docker run -d -p 6379:6379 --name redis redis:latest" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "    ❌ PROBLEM DETECTED" -ForegroundColor Red
    Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Port 8080
Write-Host "  Port 8080:" -ForegroundColor White
$portCheck = netstat -ano | Select-String ":8080" | Select-Object -First 1
if ($portCheck) {
    Write-Host "    ⚠️  Port is in use" -ForegroundColor Yellow
    Write-Host "    $portCheck" -ForegroundColor Gray
    Write-Host "    Fix: Check TROUBLESHOOTING.md - Error 3" -ForegroundColor Yellow
} else {
    Write-Host "    ✅ Available" -ForegroundColor Green
}
Write-Host ""

# Step 2: Check Compilation
Write-Host "[Step 2/5] Checking Compilation..." -ForegroundColor Yellow
Write-Host ""
try {
    Write-Host "  Compiling... (this may take a moment)" -ForegroundColor Gray
    $compileResult = mvn compile -q 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Code compiles successfully" -ForegroundColor Green
    } else {
        Write-Host "  ❌ COMPILATION FAILED" -ForegroundColor Red
        Write-Host "  Run 'mvn compile' to see detailed errors" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ❌ Compilation check failed" -ForegroundColor Red
}
Write-Host ""

# Step 3: Check Configuration
Write-Host "[Step 3/5] Checking Configuration..." -ForegroundColor Yellow
Write-Host ""

$propsFile = "src\main\resources\application.properties"
if (Test-Path $propsFile) {
    Write-Host "  ✅ application.properties exists" -ForegroundColor Green
    
    $content = Get-Content $propsFile -Raw
    
    # Check critical properties
    if ($content -match "spring.datasource.url") {
        Write-Host "  ✅ Database URL configured" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Database URL missing" -ForegroundColor Yellow
    }
    
    if ($content -match "spring.redis.host") {
        Write-Host "  ✅ Redis configured" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Redis not configured (may be intentional)" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ❌ application.properties NOT FOUND" -ForegroundColor Red
}
Write-Host ""

# Step 4: Check Dependencies
Write-Host "[Step 4/5] Checking Dependencies..." -ForegroundColor Yellow
Write-Host ""

if (Test-Path "pom.xml") {
    Write-Host "  ✅ pom.xml exists" -ForegroundColor Green
} else {
    Write-Host "  ❌ pom.xml NOT FOUND" -ForegroundColor Red
}

if (Test-Path "target\classes") {
    Write-Host "  ✅ Compiled classes exist" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  No compiled classes (run 'mvn compile')" -ForegroundColor Yellow
}
Write-Host ""

# Step 5: Try to Start (with timeout)
Write-Host "[Step 5/5] Attempting Startup Test..." -ForegroundColor Yellow
Write-Host ""
Write-Host "  Starting application (will timeout after 30 seconds)..." -ForegroundColor Gray
Write-Host "  Watch for errors below:" -ForegroundColor Gray
Write-Host ""
Write-Host "  ----------------------------------------" -ForegroundColor DarkGray

try {
    $job = Start-Job -ScriptBlock {
        Set-Location $using:PWD
        mvn spring-boot:run 2>&1
    }
    
    $timeout = 30
    $elapsed = 0
    $errorFound = $false
    
    while ($elapsed -lt $timeout -and $job.State -eq 'Running') {
        Start-Sleep -Seconds 2
        $elapsed += 2
        
        $output = Receive-Job $job 2>&1
        if ($output) {
            foreach ($line in $output) {
                if ($line -match "ERROR|Exception|Failed|refused|Unable") {
                    Write-Host "  $line" -ForegroundColor Red
                    $errorFound = $true
                } elseif ($line -match "Started OmoiservespareApplication") {
                    Write-Host "  $line" -ForegroundColor Green
                    Write-Host ""
                    Write-Host "  ✅ APPLICATION STARTED SUCCESSFULLY!" -ForegroundColor Green
                    Stop-Job $job
                    Remove-Job $job
                    Write-Host ""
                    Write-Host "========================================" -ForegroundColor Cyan
                    Write-Host "Diagnosis Complete - No Issues Found!" -ForegroundColor Green
                    Write-Host "========================================" -ForegroundColor Cyan
                    exit 0
                }
            }
        }
    }
    
    Stop-Job $job
    Remove-Job $job
    
    if ($errorFound) {
        Write-Host ""
        Write-Host "  ❌ ERRORS DETECTED DURING STARTUP" -ForegroundColor Red
    } else {
        Write-Host ""
        Write-Host "  ⚠️  Startup taking longer than expected" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "  ❌ Startup test failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "  ----------------------------------------" -ForegroundColor DarkGray
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Diagnosis Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Common fixes:" -ForegroundColor White
Write-Host "  1. Start Docker Desktop" -ForegroundColor Gray
Write-Host "  2. Start Redis: docker run -d -p 6379:6379 --name redis redis:latest" -ForegroundColor Gray
Write-Host "  3. Check PostgreSQL service is running" -ForegroundColor Gray
Write-Host "  4. See TROUBLESHOOTING.md for detailed solutions" -ForegroundColor Gray
Write-Host ""
Write-Host "To see full startup logs, run:" -ForegroundColor White
Write-Host "  mvn spring-boot:run" -ForegroundColor Cyan
Write-Host ""
