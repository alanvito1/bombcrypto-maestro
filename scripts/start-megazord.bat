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
        git checkout .
        git clean -fd

        if "%%r" == "bombcrypto-client-v2" (
            git fetch
            git checkout dev/version2_1

            git pull origin dev/version2_1
            if !errorlevel! neq 0 (
                echo %DIM_RED%[AVRE] 🥀 Check this... Sync failed in %%r.%NC%
                choice /C AC /M "Abort boot or Continue with local changes? (A/C)"
                if !errorlevel! equ 2 (
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
            git checkout main
            if !errorlevel! neq 0 (
                git checkout master
            )

            rem Tentar pull
            git pull
            if !errorlevel! neq 0 (
                echo %DIM_RED%[AVRE] 🥀 Check this... Sync failed in %%r.%NC%
                choice /C AC /M "Abort boot or Continue with local changes? (A/C)"
                if !errorlevel! equ 2 (
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
echo %WHITE%[AVRE] 🔧 Passo 2: Configurando variaveis de ambiente na raiz (Central Control Panel)...%NC%
call scripts\setup.bat

echo %RED%----------------------------------------%NC%
echo %WHITE%[AVRE] 🐧 Passo 2.5: Corrigindo quebras de linha (CRLF para LF) nos scripts do servidor...%NC%
if exist "bombcrypto-server-v2\server\deploy\" (
    powershell -Command "Get-ChildItem -Path 'bombcrypto-server-v2\server\deploy' -Filter '*.sh' -Recurse | ForEach-Object { $content = [System.IO.File]::ReadAllText($_.FullName); $content = $content -replace \"`r`n\", \"`n\"; [System.IO.File]::WriteAllText($_.FullName, $content) }"
    echo %RED%[AVRE] ❤️ Scripts .sh do servidor convertidos para formato Linux.%NC%
) else (
    echo %DIM_RED%[AVRE] 🥀 Diretorio de deploy do servidor não encontrado, pulando...%NC%
)

rem Load port variables to display later
if exist ".env" (
    for /f "tokens=1,2 delims==" %%a in (.env) do (
        set "%%a=%%b"
    )
)
if not defined MARKET_FRONTEND_PORT set "MARKET_FRONTEND_PORT=5175"

echo %RED%----------------------------------------%NC%
echo %WHITE%[AVRE] 🐳 Passo 3: Subindo containers Docker...%NC%
docker compose up -d

echo %RED%----------------------------------------%NC%
echo %RED%[AVRE] ❤️ Orchestration successful%NC%
echo %RED%----------------------------------------%NC%
echo %WHITE%🌐 Base Infrastructure Started!%NC%
echo %WHITE%🌐 Market Frontend (if enabled): http://localhost:%MARKET_FRONTEND_PORT%%NC%
echo %WHITE%🎮 Note: The Unity WebGL client is separate. Please check /docs/CLIENT_COMPILATION_MANUAL.md for instructions.%NC%
echo %WHITE%🎮 Start the client with: scripts\start-client.bat%NC%
echo %RED%----------------------------------------%NC%
