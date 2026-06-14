@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0\.."

echo ==========================================================
echo 🩺 MEGAZORD DOCTOR: Health Diagnostics ^& Pre-Flight Checks 🩺
echo ==========================================================
echo.

if exist ".env" (
    for /f "tokens=1,2 delims==" %%a in (.env) do (
        set "%%a=%%b"
    )
)
if not defined POSTGRES_PORT set "POSTGRES_PORT=5433"
if not defined REDIS_PORT set "REDIS_PORT=6380"
if not defined HARDHAT_PORT set "HARDHAT_PORT=8546"
if not defined AP_LOGIN_PORT set "AP_LOGIN_PORT=8121"
if not defined AP_MARKET_PORT set "AP_MARKET_PORT=9121"
if not defined MARKET_API_PORT set "MARKET_API_PORT=3001"
if not defined BLOCKCHAIN_CENTER_PORT set "BLOCKCHAIN_CENTER_PORT=3004"
if not defined SFS_HTTP_PORT set "SFS_HTTP_PORT=8081"
if not defined SFS_HTTPS_PORT set "SFS_HTTPS_PORT=8444"
if not defined SFS_TCP_PORT set "SFS_TCP_PORT=9934"
if not defined MARKET_FRONTEND_PORT set "MARKET_FRONTEND_PORT=5175"
if not defined CLIENT_VITE_PORT set "CLIENT_VITE_PORT=5176"

set PORTS=%POSTGRES_PORT% %REDIS_PORT% %HARDHAT_PORT% %AP_LOGIN_PORT% %AP_MARKET_PORT% %MARKET_API_PORT% %BLOCKCHAIN_CENTER_PORT% %SFS_HTTP_PORT% %SFS_HTTPS_PORT% %SFS_TCP_PORT% %MARKET_FRONTEND_PORT% %CLIENT_VITE_PORT%
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
