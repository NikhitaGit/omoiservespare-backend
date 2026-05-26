# Force application to use Java 17
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting Application with Java 17" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Java Version:" -ForegroundColor Yellow
java -version
Write-Host ""

Write-Host "Starting Spring Boot application..." -ForegroundColor Green
.\mvnw.cmd spring-boot:run
