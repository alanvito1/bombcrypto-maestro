@echo off
setlocal

set "SCRIPTS_DIR=C:\bomb\scripts"
set "BUILD_PATH=C:\bomb\bombcrypto-client-v2\unity-web-template\public\webgl\build"

echo [1/5] Starting Megazord backend...
call "%SCRIPTS_DIR%\start-megazord.bat"

echo [2/5] Patching Unity project packages...
powershell.exe -ExecutionPolicy Bypass -File "%SCRIPTS_DIR%\patch-unity.ps1"

echo [3/5] Checking WebGL build...
if not exist "%BUILD_PATH%\Build" (
    echo WARNING: WebGL build not found. Starting Unity Headless Build!
    echo NOTE: This process typically takes 5-10 minutes. Please be patient...
    call "%SCRIPTS_DIR%\build-webgl.bat"
    if %ERRORLEVEL% neq 0 (
        echo WebGL build failed. Stopping orchestration...
        pause
        exit /b 1
    )
) else (
    echo WebGL build found, skipping builder step.
)

echo [4/5] Starting Frontend Client Wrapper...
call "%SCRIPTS_DIR%\start-client.bat"

if exist ".env" (
    for /f "tokens=1,2 delims==" %%a in (.env) do (
        set "%%a=%%b"
    )
)
if not defined CLIENT_VITE_PORT set "CLIENT_VITE_PORT=5176"

echo [5/5] Opening browser...
start http://localhost:%CLIENT_VITE_PORT%

echo.
echo ================================================================
echo Zero-Touch Pipeline Executed! Game should open in your browser.
echo ================================================================
