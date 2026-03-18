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

rem Inject VITE_API_HOST into client .env
set "CLIENT_ENV=bombcrypto-client-v2\unity-web-template\.env"
if exist "%CLIENT_ENV%" (
    echo %CYAN%Injecting VITE_API_HOST into %CLIENT_ENV%...%NC%
    powershell -Command "(Get-Content -Path '%CLIENT_ENV%') -replace 'VITE_API_HOST=\"your-api-host\"', 'VITE_API_HOST=\"http://localhost:8120\"' | Set-Content -Path '%CLIENT_ENV%'"
    echo %GREEN%Injection complete.%NC%
)

echo.
echo %CYAN%NOTE: Ensure all Blockchain RPC URLs in your .env files are pointed to:%NC%
echo %CYAN%http://bombcrypto-hardhat:8545 (or http://localhost:8545 locally)%NC%
echo %CYAN%and DB connection strings use 'postgres' and 'redis' instead of localhost!%NC%
echo.
echo %GREEN%You can now start the environment with:%NC%
echo %GREEN%docker compose up -d%NC%
