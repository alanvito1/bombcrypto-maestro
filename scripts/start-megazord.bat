@echo off
setlocal enabledelayedexpansion

echo ==========================================
echo 🚀 MEGAZORD BOMB CRYPTO V2 BOOTSTRAPPER 🚀
echo ==========================================
echo Iniciando a sequencia de boot do ecossistema Bomb Crypto V2...

echo ----------------------------------------
echo 🔄 Passo 1: Sincronizando Sub-repositorios (Pre-Flight Sync)...
cd /d "%~dp0\.."

set "REPOS=bombcrypto-client-v2 bombcrypto-server-v2 bombcrypto-market-v2"
for %%r in (%REPOS%) do (
    if exist "%%r\" (
        echo 📂 Verificando %%r...
        cd "%%r"

        rem Tentar checkout na main, se falhar tenta na master
        git checkout main >nul 2>&1
        if errorlevel 1 (
            git checkout master >nul 2>&1
        )

        rem Tentar pull
        git pull
        if errorlevel 1 (
            echo ⚠️  WARNING: Sync failed in %%r.
            choice /C AC /M "Abort boot or Continue with local changes? (A/C)"
            if errorlevel 2 (
                echo ➡️  Continuando com as alteracoes locais...
            ) else (
                echo 🛑 Boot abortado.
                exit /b 1
            )
        ) else (
            echo ✅ %%r sincronizado.
        )

        cd ..
    ) else (
        echo ⚠️  Diretorio %%r nao encontrado, pulando...
    )
)

echo ----------------------------------------
echo 🔧 Passo 2: Configurando variaveis de ambiente...
call scripts\setup.bat

echo ----------------------------------------
echo 🐳 Passo 3: Subindo containers Docker...
docker compose up -d

echo ----------------------------------------
echo 🎮 Passo 4: Inicializando o Client Unity WebGL (Vite)...

cd bombcrypto-client-v2\unity-web-template

echo 📦 Verificando dependencias do Client...
call npm install --silent

echo 🚀 Iniciando Vite na porta 5174...
start "Vite - Client WebGL" cmd /c "npm run start -- --port 5174"

cd ..\..

echo ----------------------------------------
echo ✅ MEGAZORD ONLINE!
echo 🌐 Market Frontend: http://localhost:5173
echo 🎮 Client WebGL:    http://localhost:5174
echo ⚙️  Execute clean-megazord.bat ou docker compose down para desligar.
echo ----------------------------------------
