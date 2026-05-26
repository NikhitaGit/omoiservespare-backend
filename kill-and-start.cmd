@echo off
echo Killing all Java processes...
taskkill /F /IM java.exe 2>nul
timeout /t 3 /nobreak >nul

echo Starting backend...
mvnw.cmd spring-boot:run
