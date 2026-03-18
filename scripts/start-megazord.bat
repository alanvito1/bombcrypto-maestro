@echo off
setlocal enabledelayedexpansion

echo ==========================================
echo 🚀 MEGAZORD BOMB CRYPTO V2 BOOTSTRAPPER 🚀
echo ==========================================
echo Iniciando a sequencia de boot do ecossistema Bomb Crypto V2...

echo ----------------------------------------
echo 🔧 Passo 1: Configurando variaveis de ambiente...
cd /d "%~dp0\.."
call scripts\setup.bat

echo ----------------------------------------
echo 🐳 Passo 2: Subindo containers Docker...
docker compose up -d

echo ----------------------------------------
echo 🎮 Passo 3: Inicializando o Client Unity WebGL (Vite)...

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
