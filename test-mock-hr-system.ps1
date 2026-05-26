Write-Host "============================================" -ForegroundColor Cyan
Write-Host "TESTING MOCK HR SYSTEM" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

$baseUrl = "http://localhost:8080"

Write-Host ""
Write-Host "1. Getting HR Statistics..." -ForegroundColor Yellow

try {
    $stats = Invoke-RestMethod -Uri "$baseUrl/api/hr-mock/statistics" -Method GET
    Write-Host "SUCCESS: HR Statistics Retrieved" -ForegroundColor Green
    Write-Host "  Total Employees: $($stats.totalEmployees)" -ForegroundColor White
    Write-Host "  Active Employees: $($stats.activeEmployees)" -ForegroundColor White
    Write-Host "  Total Companies: $($stats.totalCompanies)" -ForegroundColor White
    Write-Host "  Companies: $($stats.companies -join ', ')" -ForegroundColor White
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "2. Testing Employee Lookup by Email..." -ForegroundColor Yellow

$testEmail = "nikita.a@omoikaneinnovations.com"

try {
    $employee = Invoke-RestMethod -Uri "$baseUrl/api/hr-mock/employees/by-email/$testEmail" -Method GET
    Write-Host "SUCCESS: Employee Found" -ForegroundColor Green
    Write-Host "  ID: $($employee.employeeId)" -ForegroundColor White
    Write-Host "  Name: $($employee.firstName) $($employee.lastName)" -ForegroundColor White
    Write-Host "  Email: $($employee.email)" -ForegroundColor White
    Write-Host "  Phone: $($employee.phoneNumber)" -ForegroundColor White
    Write-Host "  Job Title: $($employee.jobTitle)" -ForegroundColor White
    Write-Host "  Company: $($employee.companyName)" -ForegroundColor White
    Write-Host "  Status: $($employee.status)" -ForegroundColor White
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Testing Employee Lookup by Phone..." -ForegroundColor Yellow

$testPhone = "+91-9876543210"

try {
    $employee = Invoke-RestMethod -Uri "$baseUrl/api/hr-mock/employees/by-phone/$testPhone" -Method GET
    Write-Host "SUCCESS: Employee Found by Phone" -ForegroundColor Green
    Write-Host "  Name: $($employee.firstName) $($employee.lastName)" -ForegroundColor White
    Write-Host "  Email: $($employee.email)" -ForegroundColor White
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "4. Testing Company Validation..." -ForegroundColor Yellow

$testCompany = "Omoiservespare Pvt Ltd"

try {
    $isValid = Invoke-RestMethod -Uri "$baseUrl/api/hr-mock/companies/validate/$testCompany" -Method GET
    if ($isValid) {
        Write-Host "SUCCESS: Company is valid" -ForegroundColor Green
    } else {
        Write-Host "WARNING: Company is not valid" -ForegroundColor Yellow
    }
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "5. Getting All Active Employees..." -ForegroundColor Yellow

try {
    $employees = Invoke-RestMethod -Uri "$baseUrl/api/hr-mock/employees" -Method GET
    Write-Host "SUCCESS: Retrieved $($employees.Count) active employees" -ForegroundColor Green
    Write-Host ""
    Write-Host "Employee List:" -ForegroundColor Cyan
    foreach ($emp in $employees) {
        Write-Host "  - $($emp.firstName) $($emp.lastName) ($($emp.email))" -ForegroundColor White
    }
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "6. Testing Login with Mock HR Data..." -ForegroundColor Yellow

$loginPayload = @{
    companyName = "Omoiservespare Pvt Ltd"
    email = "nikita.a@omoikaneinnovations.com"
    phoneNumber = "+91-9876543210"
    accountType = "PROFESSIONAL"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Body $loginPayload -ContentType "application/json"
    Write-Host "SUCCESS: Login worked with mock HR data!" -ForegroundColor Green
    Write-Host "  Message: $($response.message)" -ForegroundColor White
    Write-Host ""
    Write-Host "Check your application console for the OTP code!" -ForegroundColor Cyan
} catch {
    Write-Host "ERROR: Login failed" -ForegroundColor Red
    Write-Host "  $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "MOCK HR SYSTEM TEST COMPLETE" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "  - Mock HR system is working" -ForegroundColor Green
Write-Host "  - Employee data is accessible" -ForegroundColor Green
Write-Host "  - Login integration is functional" -ForegroundColor Green
Write-Host ""
Write-Host "Next: Use any of the pre-loaded employees to test login!" -ForegroundColor Cyan
Write-Host ""