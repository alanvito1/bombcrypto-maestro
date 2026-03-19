@echo off
set "UNITY_PATH=C:\Program Files\Unity\Hub\Editor\2022.3.62f3\Editor\Unity.exe"
set "PROJECT_PATH=C:\bomb\bombcrypto-client-v2"
set "BUILD_PATH=C:\bomb\bombcrypto-client-v2\unity-web-template\public\webgl\build"
set "LOG_FILE=C:\bomb\unity-build.log"
set "EDITOR_DIR=%PROJECT_PATH%\Assets\Editor"
set "AUTO_BUILDER=%EDITOR_DIR%\AutoBuilder.cs"

echo Creating Editor directory if it doesn't exist...
if not exist "%EDITOR_DIR%" mkdir "%EDITOR_DIR%"

echo Checking if Unity is already running...
tasklist /FI "IMAGENAME eq Unity.exe" 2>NUL | find /I /N "Unity.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo.
    echo [ERROR] Unity is already running with this project open.
    echo CLOSE ALL UNITY WINDOWS BEFORE RUNNING THIS BUILD.
    echo.
    pause
    exit /b 1
)

echo Starting headless Unity WebGL build...
start /wait "" "%UNITY_PATH%" -quit -batchmode -buildTarget WebGL -nographics -projectPath "%PROJECT_PATH%" -executeMethod AutoBuilder.BuildWebGL -logFile "%LOG_FILE%"
set BUILD_CMD_RESULT=%ERRORLEVEL%

if exist "%BUILD_PATH%\Build" (
    echo Build complete! Check %LOG_FILE% for details.
    exit /b 0
) else (
    echo Build failed! Check %LOG_FILE% for details.
    exit /b 1
)
