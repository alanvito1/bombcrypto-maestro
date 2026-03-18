@echo off
setlocal enabledelayedexpansion

rem Set up basic ANSI equivalent colors if possible (Windows 10+)
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "CYAN=%ESC%[36m"
set "GREEN=%ESC%[32m"
set "RED=%ESC%[31m"
set "NC=%ESC%[0m"

echo %CYAN%==========================================%NC%
echo %CYAN%🚀 MEGAZORD BOMB CRYPTO V2 BOOTSTRAPPER 🚀%NC%
echo %CYAN%==========================================%NC%
echo %CYAN%Iniciando a sequencia de boot do ecossistema Bomb Crypto V2...%NC%

echo %CYAN%----------------------------------------%NC%
echo %CYAN%🔄 Passo 1: Sincronizando Sub-repositorios (Pre-Flight Sync)...%NC%
cd /d "%~dp0\.."

set "REPOS=bombcrypto-client-v2 bombcrypto-server-v2 bombcrypto-market-v2"
for %%r in (%REPOS%) do (
    if exist "%%r\" (
        echo %CYAN%📂 Verificando %%r...%NC%
        cd "%%r"

        rem Tentar checkout na main, se falhar tenta na master
        git checkout main >nul 2>&1
        if errorlevel 1 (
            git checkout master >nul 2>&1
        )

        rem Tentar pull
        git pull >nul 2>&1
        if errorlevel 1 (
            echo %RED%⚠️  WARNING: Sync failed in %%r.%NC%
            choice /C AC /M "Abort boot or Continue with local changes? (A/C)"
            if errorlevel 2 (
                echo %GREEN%➡️  Continuando com as alteracoes locais...%NC%
            ) else (
                echo %RED%🛑 Boot abortado.%NC%
                exit /b 1
            )
        ) else (
            echo %GREEN%✅ %%r sincronizado.%NC%
        )

        cd ..
    ) else (
        echo %RED%⚠️  Diretorio %%r nao encontrado, pulando...%NC%
    )
)

echo %CYAN%----------------------------------------%NC%
echo %CYAN%🔧 Passo 2: Configurando variaveis de ambiente...%NC%
call scripts\setup.bat

echo %CYAN%----------------------------------------%NC%
echo %CYAN%🐧 Passo 2.5: Corrigindo quebras de linha (CRLF para LF) nos scripts do servidor...%NC%
if exist "bombcrypto-server-v2\server\deploy\" (
    powershell -Command "Get-ChildItem -Path 'bombcrypto-server-v2\server\deploy' -Filter '*.sh' -Recurse | ForEach-Object { $content = [System.IO.File]::ReadAllText($_.FullName); $content = $content -replace \"`r`n\", \"`n\"; [System.IO.File]::WriteAllText($_.FullName, $content) }"
    echo %GREEN%✅ Scripts .sh do servidor convertidos para formato Linux.%NC%
) else (
    echo %CYAN%Diretorio de deploy do servidor não encontrado, pulando...%NC%
)

echo %CYAN%----------------------------------------%NC%
echo %CYAN%🐳 Passo 3: Subindo containers Docker...%NC%
docker compose up -d

echo %CYAN%----------------------------------------%NC%
echo %CYAN%🎮 Passo 4: Inicializando o Client Unity WebGL (Vite)...%NC%

cd bombcrypto-client-v2\unity-web-template

echo %CYAN%📦 Verificando dependencias do Client...%NC%
call npm install --silent >nul 2>&1

echo %GREEN%🚀 Iniciando Vite na porta 5174...%NC%
start "Vite - Client WebGL" cmd /c "npm run start --silent -- --port 5174 >nul 2>&1"

cd ..\..

echo %CYAN%----------------------------------------%NC%
echo %GREEN%   __  __ _____ ____    _   _____ ___  ____  ____    %NC%
echo %GREEN%  ^|  \/  ^|  ___/ ___^|  / \ ^|__  /^| _ \^|  _ \^|  _ \   %NC%
echo %GREEN%  ^| ^|\/^| ^| ^|_ ^| ^|  _  / _ \  / /^| ^| ^| ^|_) ^| ^| ^| ^|  %NC%
echo %GREEN%  ^| ^|  ^| ^|  _^|^| ^|_^| ^|/ ___ \/ /_^| ^|_^| ^|  _ ^<^| ^|_^| ^|  %NC%
echo %GREEN%  ^|_^|  ^|_^|_^|   \____/_/   \_\____\___/^|_^| \_\____/   %NC%
echo %GREEN%                                                     %NC%
echo %GREEN%                 O N L I N E                         %NC%
echo %CYAN%----------------------------------------%NC%
echo %GREEN%🌐 Market Frontend: http://localhost:5173%NC%
echo %GREEN%🎮 Client WebGL:    http://localhost:5174%NC%
echo %CYAN%⚙️  Execute clean-megazord.bat ou docker compose down para desligar.%NC%
echo %CYAN%----------------------------------------%NC%
