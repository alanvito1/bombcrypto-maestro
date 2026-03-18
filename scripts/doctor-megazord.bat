@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0\.."

echo ==========================================================
echo 🩺 MEGAZORD DOCTOR: Health Diagnostics ^& Pre-Flight Checks 🩺
echo ==========================================================
echo.

set PORTS=5432 6379 8545 8120 9120 3000 3003 8080 8443 9933 5173 5174
set OCCUPIED_PORTS=0

echo 🔍 PRE-FLIGHT: Checking for occupied ports...
for %%P in (%PORTS%) do (
    netstat -ano ^| findstr ":%%P " >nul
    if !errorlevel! equ 0 (
        echo ❌ ALERT: Port %%P is already in use!
        set /a OCCUPIED_PORTS+=1
    )
)

if !OCCUPIED_PORTS! gtr 0 (
    echo.
    echo ⚠️  WARNING: Found !OCCUPIED_PORTS! occupied ports.
    echo 💡 TIP: Run '.\scripts\clean-megazord.bat' to terminate zombie processes before starting the Megazord.
) else (
    echo ✅ ALL CLEAR: All essential ports are free.
)

echo.
echo 🐳 POST-BOOT: Checking Docker Container Health...

docker info >nul 2>&1
if !errorlevel! neq 0 (
    echo ❌ ERROR: Docker daemon is not running. Please start Docker.
    goto :eof
)

echo ✅ RUNNING CONTAINERS DETECTED:
docker ps --filter "name=bombcrypto" --format "   - {{.Names}}"

echo.
echo 🩺 Diagnosis complete.
