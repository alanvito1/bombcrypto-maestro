@echo off
setlocal enabledelayedexpansion

rem 🌹 SECURITY GATEKEEPER
rem Guard: AVRE
rem -------------------------
rem Identity verification layer.

rem Set up basic ANSI equivalent colors if possible (Windows 10+)
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "WHITE=%ESC%[1;37m"
set "RED=%ESC%[1;31m"
set "DIM_RED=%ESC%[0;31m"
set "NC=%ESC%[0m"

echo %RED%==========================================================%NC%
echo %WHITE%[AVRE] 🌹 TERRA ARRASADA: Cleaning up the Megazord Environment...%NC%
echo %RED%==========================================================%NC%
echo.

echo %WHITE%[AVRE] 🐳 Stopping Docker containers and removing volumes...%NC%
cd /d "%~dp0\.."
docker compose down -v

if exist ".env" (
    for /f "tokens=1,2 delims==" %%a in (.env) do (
        set "%%a=%%b"
    )
)
if not defined MARKET_FRONTEND_PORT set "MARKET_FRONTEND_PORT=5175"
if not defined CLIENT_VITE_PORT set "CLIENT_VITE_PORT=5176"

echo %WHITE%[AVRE] 🌐 Killing Zombie Market Frontend processes (Vite) on port %MARKET_FRONTEND_PORT%...%NC%
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":%MARKET_FRONTEND_PORT% " ^| findstr "LISTENING"') do (
    taskkill /F /PID %%a >nul 2>&1
    if !errorlevel! equ 0 echo %RED%[AVRE] ❤️ Killed process %%a.%NC%
)

echo %WHITE%[AVRE] 🎮 Killing Zombie Unity WebGL Client processes (Vite) on port %CLIENT_VITE_PORT%...%NC%
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":%CLIENT_VITE_PORT% " ^| findstr "LISTENING"') do (
    taskkill /F /PID %%a >nul 2>&1
    if !errorlevel! equ 0 echo %RED%[AVRE] ❤️ Killed process %%a.%NC%
)

echo %WHITE%[AVRE] 🔄 Running general cleanup for Vite and Node processes...%NC%
taskkill /F /IM "node.exe" >nul 2>&1

echo.
echo %RED%[AVRE] ❤️ CLEANUP COMPLETE: Environment is clean and ready for a fresh start.%NC%
echo %WHITE%[AVRE] 💡 NOTE: .env files were not deleted.%NC%
