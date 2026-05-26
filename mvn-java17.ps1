# Wrapper to run Maven commands with Java 17
# Usage: powershell -ExecutionPolicy Bypass -File mvn-java17.ps1 install
# Usage: powershell -ExecutionPolicy Bypass -File mvn-java17.ps1 clean compile

param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$MavenArgs
)

# Force Java 17
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

Write-Host "Using Java 17 from: $env:JAVA_HOME" -ForegroundColor Green

# Run Maven with provided arguments
if ($MavenArgs.Count -gt 0) {
    $command = ".\mvnw.cmd " + ($MavenArgs -join " ")
    Write-Host "Running: $command" -ForegroundColor Cyan
    Write-Host ""
    Invoke-Expression $command
} else {
    Write-Host "No Maven arguments provided!" -ForegroundColor Red
    Write-Host "Usage: powershell -ExecutionPolicy Bypass -File mvn-java17.ps1 <maven-goals>" -ForegroundColor Yellow
    Write-Host "Example: powershell -ExecutionPolicy Bypass -File mvn-java17.ps1 clean install" -ForegroundColor Yellow
}
