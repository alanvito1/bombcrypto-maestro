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

echo %RED%==========================================%NC%
echo %WHITE%    db    Y88b  /  88888b  888888 %NC%
echo %WHITE%   dPYb    Y88 /   88   88 88__   %NC%
echo %WHITE%  dP__Yb    Y8/    88   88 88""   %NC%
echo %WHITE% dP""""Yb    Y     88888P  888888 %NC%
echo %RED%==========================================%NC%
echo %WHITE%[AVRE] 🌹 System active...%NC%
echo %WHITE%[AVRE] 🌹 Iniciando a sequencia de boot do ecossistema Bomb Crypto V2...%NC%

echo %RED%----------------------------------------%NC%
echo %WHITE%[AVRE] 🔄 Passo 1: Sincronizando Sub-repositorios (Pre-Flight Sync)...%NC%
cd /d "%~dp0\.."

set "REPOS=bombcrypto-client-v2 bombcrypto-server-v2 bombcrypto-market-v2"
for %%r in (%REPOS%) do (
    if exist "%%r\" (
        echo %WHITE%[AVRE] 📂 Verificando %%r...%NC%
        cd "%%r"

        rem 🐙 FAIL-SAFE GIT SYNC: Clean any uncommitted changes or untracked files
        git checkout . >nul 2>&1
        git clean -fd >nul 2>&1

        if "%%r" == "bombcrypto-client-v2" (
            git fetch >nul 2>&1
            git checkout dev/version2_1 >nul 2>&1

            git pull origin dev/version2_1 >nul 2>&1
            if errorlevel 1 (
                echo %DIM_RED%[AVRE] 🥀 Check this... Sync failed in %%r.%NC%
                choice /C AC /M "Abort boot or Continue with local changes? (A/C)"
                if errorlevel 2 (
                    echo %WHITE%[AVRE] ❤️ Continuando com as alteracoes locais...%NC%
                ) else (
                    echo %RED%[AVRE] 🛑 Boot abortado.%NC%
                    exit /b 1
                )
            ) else (
                echo %RED%[AVRE] ❤️ %%r sincronizado.%NC%
            )
        ) else (
            rem Tentar checkout na main, se falhar tenta na master
            git checkout main >nul 2>&1
            if errorlevel 1 (
                git checkout master >nul 2>&1
            )

            rem Tentar pull
            git pull >nul 2>&1
            if errorlevel 1 (
                echo %DIM_RED%[AVRE] 🥀 Check this... Sync failed in %%r.%NC%
                choice /C AC /M "Abort boot or Continue with local changes? (A/C)"
                if errorlevel 2 (
                    echo %WHITE%[AVRE] ❤️ Continuando com as alteracoes locais...%NC%
                ) else (
                    echo %RED%[AVRE] 🛑 Boot abortado.%NC%
                    exit /b 1
                )
            ) else (
                echo %RED%[AVRE] ❤️ %%r sincronizado.%NC%
            )
        )

        cd ..
    ) else (
        echo %DIM_RED%[AVRE] 🥀 Diretorio %%r nao encontrado, pulando...%NC%
    )
)

echo %RED%----------------------------------------%NC%
echo %WHITE%[AVRE] 🔧 Passo 2: Configurando variaveis de ambiente...%NC%
call scripts\setup.bat

echo %RED%----------------------------------------%NC%
echo %WHITE%[AVRE] 🐧 Passo 2.5: Corrigindo quebras de linha (CRLF para LF) nos scripts do servidor...%NC%
if exist "bombcrypto-server-v2\server\deploy\" (
    powershell -Command "Get-ChildItem -Path 'bombcrypto-server-v2\server\deploy' -Filter '*.sh' -Recurse | ForEach-Object { $content = [System.IO.File]::ReadAllText($_.FullName); $content = $content -replace \"`r`n\", \"`n\"; [System.IO.File]::WriteAllText($_.FullName, $content) }"
    echo %RED%[AVRE] ❤️ Scripts .sh do servidor convertidos para formato Linux.%NC%
) else (
    echo %DIM_RED%[AVRE] 🥀 Diretorio de deploy do servidor não encontrado, pulando...%NC%
)

echo %RED%----------------------------------------%NC%
echo %WHITE%[AVRE] 🐳 Passo 3: Subindo containers Docker...%NC%
docker compose up -d

echo %RED%----------------------------------------%NC%
echo %WHITE%[AVRE] 🎮 Passo 4: Inicializando o Client Unity WebGL (Vite)...%NC%

cd bombcrypto-client-v2\unity-web-template

echo %WHITE%[AVRE] 📦 Verificando dependencias do Client...%NC%
call npm install --silent >nul 2>&1

echo %RED%[AVRE] ❤️ Iniciando Vite na porta 5174...%NC%
start "Vite - Client WebGL" cmd /c "npm run start --silent -- --port 5174 >nul 2>&1"

cd ..\..

echo %RED%----------------------------------------%NC%
echo %RED%[AVRE] ❤️ Build successful%NC%
echo %RED%----------------------------------------%NC%
echo %WHITE%🌐 Market Frontend: http://localhost:5173%NC%
echo %WHITE%🎮 Client WebGL:    http://localhost:5174%NC%
echo %RED%⚙️  Execute clean-megazord.bat ou docker compose down para desligar.%NC%
echo %RED%----------------------------------------%NC%
