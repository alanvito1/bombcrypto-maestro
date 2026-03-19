@echo off
set "WRAPPER_DIR=C:\bomb\bombcrypto-client-v2\unity-web-template"

echo Changing directory to %WRAPPER_DIR%...
cd /d "%WRAPPER_DIR%"

if not exist node_modules (
    echo Missing node_modules. Running npm install...
    call npm install
)

echo Starting Vite server in background...
start /b cmd /c npm run dev
