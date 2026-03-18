@echo off
setlocal enabledelayedexpansion

echo ==========================================================
echo 🧹 TERRA ARRASADA: Cleaning up the Megazord Environment 🧹
echo ==========================================================
echo.

echo 🐳 Stopping Docker containers and removing volumes...
cd /d "%~dp0\.."
docker compose down -v

echo 🌐 Killing Zombie Market Frontend processes (Vite) on port 5173...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":5173 " ^| findstr "LISTENING"') do (
    taskkill /F /PID %%a >nul 2>&1
    if !errorlevel! equ 0 echo ✅ Killed process %%a.
)

echo 🎮 Killing Zombie Unity WebGL Client processes (Vite) on port 5174...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":5174 " ^| findstr "LISTENING"') do (
    taskkill /F /PID %%a >nul 2>&1
    if !errorlevel! equ 0 echo ✅ Killed process %%a.
)

echo 🔄 Running general cleanup for Vite and Node processes...
taskkill /F /IM "node.exe" >nul 2>&1

echo.
echo ✅ CLEANUP COMPLETE: Environment is clean and ready for a fresh start.
echo 💡 NOTE: .env files were not deleted.
