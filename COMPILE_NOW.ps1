$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

Write-Host "Compiling with Java 17..." -ForegroundColor Cyan
.\mvnw.cmd clean compile -DskipTests
