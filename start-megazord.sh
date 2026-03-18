#!/bin/bash

# ==========================================
# 🚀 MEGAZORD BOMB CRYPTO V2 BOOTSTRAPPER 🚀
# ==========================================
echo "Iniciando a sequencia de boot do ecossistema Bomb Crypto V2..."

# 1. Configurar variaveis de ambiente (.env)
echo "----------------------------------------"
echo "🔧 Passo 1: Configurando variaveis de ambiente..."
./init-bomb.sh

# 2. Subir infraestrutura Base (Bancos, Hardhat, Server, Market, etc)
echo "----------------------------------------"
echo "🐳 Passo 2: Subindo containers Docker..."
docker compose up -d

# Funcao de Graceful Shutdown
cleanup() {
    echo ""
    echo "🛑 Detectado sinal de interrupcao (Ctrl+C). Iniciando Graceful Shutdown..."

    # Derrubar processo do Client (Vite)
    if [ -n "$CLIENT_PID" ]; then
        echo "🔪 Encerrando Client WebGL (PID: $CLIENT_PID)..."
        kill $CLIENT_PID 2>/dev/null
    fi

    # Desligar todos os containers do docker-compose
    echo "🐳 Desligando infraestrutura Docker..."
    docker compose down

    echo "✅ Shutdown concluido com seguranca. Ate a proxima!"
    exit 0
}

# 3. Registrar o Trap para capturar sinais de termino (SIGINT / SIGTERM)
trap cleanup SIGINT SIGTERM

# 4. Iniciar o Frontend do Client Unity WebGL (em background para nao travar o terminal)
echo "----------------------------------------"
echo "🎮 Passo 3: Inicializando o Client Unity WebGL (Vite)..."

cd bombcrypto-client-v2/unity-web-template

echo "📦 Verificando dependencias do Client..."
npm install --silent

echo "🚀 Iniciando Vite na porta 5174..."
npm run start -- --port 5174 &
CLIENT_PID=$!

cd ../..

echo "----------------------------------------"
echo "✅ MEGAZORD ONLINE!"
echo "🌐 Market Frontend: http://localhost:5173"
echo "🎮 Client WebGL:    http://localhost:5174"
echo "⚙️  Pressione Ctrl+C para desligar todo o ecossistema."
echo "----------------------------------------"

# 5. Manter o terminal vivo aguardando o processo do Client
wait $CLIENT_PID
