@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0\.."

rem Set up basic ANSI equivalent colors if possible (Windows 10+)
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "CYAN=%ESC%[36m"
set "GREEN=%ESC%[32m"
set "RED=%ESC%[31m"
set "NC=%ESC%[0m"

echo %CYAN%Creating the Central Control Panel at Root...%NC%

if exist ".env.example" (
    if not exist ".env" (
        echo %GREEN%Creating root .env from .env.example%NC%
        copy ".env.example" ".env" > nul
    ) else (
        echo %CYAN%Root .env already exists, skipping.%NC%
    )
)

rem Load AP_LOGIN_PORT to inject it into the Vite frontend
if exist ".env" (
    for /f "tokens=1,2 delims==" %%a in (.env) do (
        set "%%a=%%b"
    )
)
if not defined AP_LOGIN_PORT set "AP_LOGIN_PORT=8120"

rem Use Vite .env.local trick for Unity WebGL Client to bypass config conflicts
echo %CYAN%Creating .env.local for Client with VITE_API_HOST and Unity config...%NC%
if not exist "bombcrypto-client-v2\unity-web-template" mkdir "bombcrypto-client-v2\unity-web-template"
(
echo VITE_API_HOST="http://localhost:%AP_LOGIN_PORT%/web"
echo VITE_UNITY_FOLDER=./webgl/build
echo VITE_LOADER_URL_EXTENSION=/webgl.loader.js
echo VITE_DATA_URL_EXTENSION=/webgl.data
echo VITE_DATA_URL_MOBILE_EXTENSION=/mobile.data.br
echo VITE_FRAMEWORK_URL_EXTENSION=/webgl.framework.js
echo VITE_CODE_URL_EXTENSION=/webgl.wasm
) > bombcrypto-client-v2\unity-web-template\.env.local
echo %GREEN%.env.local trick applied successfully.%NC%

echo.
echo %CYAN%NOTE: All environment configurations are now managed exclusively in the root .env file!%NC%
echo %CYAN%There is no need to manually configure sub-repositories anymore.%NC%
echo.
echo %GREEN%You can now start the environment via the start-megazord scripts.%NC%
