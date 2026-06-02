Write-Host "========================================"
Write-Host "Building for Production with Java 17"
Write-Host "========================================"

# Set Java 17 path
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

Write-Host "`nJava Version:"
java -version

Write-Host "`n========================================"
Write-Host "Step 1: Clean and Compile"
Write-Host "========================================"
mvn clean compile

Write-Host "`n========================================"
Write-Host "Step 2: Run Tests"
Write-Host "========================================"
mvn test

Write-Host "`n========================================"
Write-Host "Step 3: Package (Skip Tests)"
Write-Host "========================================"
mvn package -DskipTests

Write-Host "`n========================================"
Write-Host "Build Complete!"
Write-Host "========================================"
Write-Host "JAR file location: target\omoiservespare-0.0.1-SNAPSHOT.jar"
Write-Host ""
Write-Host "To deploy to production:"
Write-Host "1. Set environment variables on your server"
Write-Host "2. Upload the JAR file"
Write-Host "3. Run: java -jar omoiservespare-0.0.1-SNAPSHOT.jar"
