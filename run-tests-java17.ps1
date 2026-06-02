Write-Host "========================================"
Write-Host "Running Tests with Java 17"
Write-Host "========================================"

# Set Java 17 path
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

Write-Host "`nJava Version:"
java -version

Write-Host "`nRunning Maven Tests..."
mvn clean test

Write-Host "`n========================================"
Write-Host "Tests Complete"
Write-Host "========================================"
