#!/bin/bash

# ==========================================
# 🚀 MEGAZORD BOMB CRYPTO V2 BOOTSTRAPPER 🚀
# ==========================================
echo "Iniciando a sequencia de boot do ecossistema Bomb Crypto V2..."

# Vai para o root do projeto garantindo que funcione de qualquer pasta
cd "$(dirname "$0")/.."

# 1. Sincronizar sub-repositorios (Pre-Flight Sync)
echo "----------------------------------------"
echo "🔄 Passo 1: Sincronizando Sub-repositorios (Pre-Flight Sync)..."

REPOS=("bombcrypto-client-v2" "bombcrypto-server-v2" "bombcrypto-market-v2")

for repo in "${REPOS[@]}"; do
    if [ -d "$repo" ]; then
        echo "📂 Verificando $repo..."
        cd "$repo" || continue

        # Tentar checkout na main, se falhar tenta na master
        if ! git checkout main 2>/dev/null; then
            git checkout master 2>/dev/null
        fi

        # Tentar pull
        if ! git pull; then
            echo "⚠️  WARNING: Sync failed in $repo."
            while true; do
                read -p "Abort boot or Continue with local changes? (A/C): " choice
                case "$choice" in
                    [Aa]* ) echo "🛑 Boot abortado."; exit 1;;
                    [Cc]* ) echo "➡️  Continuando com as alteracoes locais..."; break;;
                    * ) echo "Por favor, responda A ou C.";;
                esac
            done
        else
            echo "✅ $repo sincronizado."
        fi

        cd ..
    else
        echo "⚠️  Diretorio $repo nao encontrado, pulando..."
    fi
done

# 2. Configurar variaveis de ambiente (.env)
echo "----------------------------------------"
echo "🔧 Passo 2: Configurando variaveis de ambiente..."
./scripts/init-bomb.sh

# 3. Subir infraestrutura Base (Bancos, Hardhat, Server, Market, etc)
echo "----------------------------------------"
echo "🐳 Passo 3: Subindo containers Docker..."
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

# 4. Registrar o Trap para capturar sinais de termino (SIGINT / SIGTERM)
trap cleanup SIGINT SIGTERM

# 5. Iniciar o Frontend do Client Unity WebGL (em background para nao travar o terminal)
echo "----------------------------------------"
echo "🎮 Passo 4: Inicializando o Client Unity WebGL (Vite)..."

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

# 6. Manter o terminal vivo aguardando o processo do Client
wait $CLIENT_PID
