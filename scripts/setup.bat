@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0\.."

rem Set up basic ANSI equivalent colors if possible (Windows 10+)
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "CYAN=%ESC%[36m"
set "GREEN=%ESC%[32m"
set "RED=%ESC%[31m"
set "NC=%ESC%[0m"

echo %CYAN%Copying .env template files to .env where .env is missing...%NC%

rem Strict list of directories
set "DIRS=bombcrypto-client-v2\unity-web-template bombcrypto-server-v2\api\login bombcrypto-server-v2\api\market bombcrypto-server-v2\server bombcrypto-market-v2\frontend bombcrypto-market-v2\backend bombcrypto-market-v2\detect-transfer ."

for %%d in (%DIRS%) do (
    if exist "%%d\.env.example" (
        if not exist "%%d\.env" (
            echo %GREEN%Creating %%d\.env from .env.example%NC%
            copy "%%d\.env.example" "%%d\.env" > nul
        ) else (
            echo %CYAN%%%d\.env already exists, skipping.%NC%
        )
        if "%%d" == "bombcrypto-market-v2\backend" (
            if not exist "%%d\.prod.bsc.env" (
                echo %GREEN%Creating %%d\.prod.bsc.env from .env.example%NC%
                copy "%%d\.env.example" "%%d\.prod.bsc.env" > nul
            ) else (
                echo %CYAN%%%d\.prod.bsc.env already exists, skipping.%NC%
            )
        )
    ) else if exist "%%d\.env.sample" (
        if not exist "%%d\.env" (
            echo %GREEN%Creating %%d\.env from .env.sample%NC%
            copy "%%d\.env.sample" "%%d\.env" > nul
        ) else (
            echo %CYAN%%%d\.env already exists, skipping.%NC%
        )
        if "%%d" == "bombcrypto-market-v2\backend" (
            if not exist "%%d\.prod.bsc.env" (
                echo %GREEN%Creating %%d\.prod.bsc.env from .env.sample%NC%
                copy "%%d\.env.sample" "%%d\.prod.bsc.env" > nul
            ) else (
                echo %CYAN%%%d\.prod.bsc.env already exists, skipping.%NC%
            )
        )
    )
)

rem --- WebGL Asset Injection ---
echo %CYAN%[AVRE] 🌹 Checking for WebGL assets in /game-assets/webgl/...%NC%
if exist ".\game-assets\webgl" (
    echo %GREEN%[AVRE] ❤️ WebGL assets found! Injecting into bombcrypto-client-v2...%NC%
    if not exist "bombcrypto-client-v2\unity-web-template\public\webgl\build" mkdir "bombcrypto-client-v2\unity-web-template\public\webgl\build"
    xcopy /e /y /i ".\game-assets\webgl\*" "bombcrypto-client-v2\unity-web-template\public\webgl\build\" > nul
) else (
    echo %RED%[AVRE] ⚠️ WARNING: WebGL assets not found in /game-assets/webgl/. Game will not render.%NC%
)
rem -----------------------------

rem Use Vite .env.local trick for Unity WebGL Client to bypass config conflicts
echo %CYAN%Creating .env.local for Client with VITE_API_HOST and Unity config...%NC%
(
echo VITE_API_HOST="http://localhost:8120/web"
echo VITE_UNITY_FOLDER=./webgl/build
echo VITE_LOADER_URL_EXTENSION=/webgl.loader.js
echo VITE_DATA_URL_EXTENSION=/webgl.data
echo VITE_DATA_URL_MOBILE_EXTENSION=/mobile.data.br
echo VITE_FRAMEWORK_URL_EXTENSION=/webgl.framework.js
echo VITE_CODE_URL_EXTENSION=/webgl.wasm
) > bombcrypto-client-v2\unity-web-template\.env.local
echo %GREEN%.env.local trick applied successfully.%NC%

echo.
echo %CYAN%NOTE: Ensure all Blockchain RPC URLs in your .env files are pointed to:%NC%
echo %CYAN%http://bombcrypto-hardhat:8545 (or http://localhost:8545 locally)%NC%
echo %CYAN%and DB connection strings use 'postgres' and 'redis' instead of localhost!%NC%
echo.
echo %GREEN%You can now start the environment with:%NC%
echo %GREEN%docker compose up -d%NC%
