@echo off
setlocal enabledelayedexpansion

echo Copying .env.example files to .env where .env is missing...
for /R %%f in (.env.example) do (
    set "example=%%f"
    set "env=!example:.example=!"
    if not exist "!env!" (
        echo Creating !env!
        copy "%%f" "!env!" > nul
    ) else (
        echo !env! already exists, skipping.
    )
)

echo.
echo NOTE: Ensure all Blockchain RPC URLs in your .env files are pointed to:
echo http://bombcrypto-hardhat:8545 (or http://localhost:8545 locally)
echo and DB connection strings use 'postgres' and 'redis' instead of localhost!
echo.
echo You can now start the environment with:
echo docker compose up -d
