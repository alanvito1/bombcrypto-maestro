@echo off
cd /d "%~dp0\.."

set "WRAPPER_DIR=%cd%\bombcrypto-client-v2\unity-web-template"

if exist ".env" (
    for /f "tokens=1,2 delims==" %%a in (.env) do (
        set "%%a=%%b"
    )
)
if not defined CLIENT_VITE_PORT set "CLIENT_VITE_PORT=5176"

echo Changing directory to %WRAPPER_DIR%...
cd /d "%WRAPPER_DIR%"

if not exist node_modules (
    echo Missing node_modules. Running npm install...
    call npm install
)

echo Starting Vite server in background on port %CLIENT_VITE_PORT%...
start /b cmd /c npm run start -- --port %CLIENT_VITE_PORT%
