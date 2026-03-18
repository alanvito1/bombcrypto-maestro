#!/bin/bash

# ANSI Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ==========================================
# 🚀 MEGAZORD BOMB CRYPTO V2 BOOTSTRAPPER 🚀
# ==========================================
echo -e "${CYAN}==========================================${NC}"
echo -e "${CYAN}🚀 MEGAZORD BOMB CRYPTO V2 BOOTSTRAPPER 🚀${NC}"
echo -e "${CYAN}==========================================${NC}"
echo -e "${CYAN}Iniciando a sequencia de boot do ecossistema Bomb Crypto V2...${NC}"

# Vai para o root do projeto garantindo que funcione de qualquer pasta
cd "$(dirname "$0")/.."

# 1. Sincronizar sub-repositorios (Pre-Flight Sync)
echo -e "${CYAN}----------------------------------------${NC}"
echo -e "${CYAN}🔄 Passo 1: Sincronizando Sub-repositorios (Pre-Flight Sync)...${NC}"

REPOS=("bombcrypto-client-v2" "bombcrypto-server-v2" "bombcrypto-market-v2")

for repo in "${REPOS[@]}"; do
    if [ -d "$repo" ]; then
        echo -e "${CYAN}📂 Verificando $repo...${NC}"
        cd "$repo" || continue

        # Tentar checkout na main, se falhar tenta na master
        if ! git checkout main 2>/dev/null; then
            git checkout master 2>/dev/null
        fi

        # Tentar pull
        if ! git pull > /dev/null 2>&1; then
            echo -e "${RED}⚠️  WARNING: Sync failed in $repo.${NC}"
            while true; do
                read -p "Abort boot or Continue with local changes? (A/C): " choice
                case "$choice" in
                    [Aa]* ) echo -e "${RED}🛑 Boot abortado.${NC}"; exit 1;;
                    [Cc]* ) echo -e "${GREEN}➡️  Continuando com as alteracoes locais...${NC}"; break;;
                    * ) echo -e "${CYAN}Por favor, responda A ou C.${NC}";;
                esac
            done
        else
            echo -e "${GREEN}✅ $repo sincronizado.${NC}"
        fi

        cd ..
    else
        echo -e "${RED}⚠️  Diretorio $repo nao encontrado, pulando...${NC}"
    fi
done

# 2. Configurar variaveis de ambiente (.env)
echo -e "${CYAN}----------------------------------------${NC}"
echo -e "${CYAN}🔧 Passo 2: Configurando variaveis de ambiente...${NC}"
./scripts/init-bomb.sh

# 3. Subir infraestrutura Base (Bancos, Hardhat, Server, Market, etc)
echo -e "${CYAN}----------------------------------------${NC}"
echo -e "${CYAN}🐳 Passo 3: Subindo containers Docker...${NC}"
docker compose up -d

# Funcao de Graceful Shutdown
cleanup() {
    echo ""
    echo -e "${RED}🛑 Detectado sinal de interrupcao (Ctrl+C). Iniciando Graceful Shutdown...${NC}"

    # Derrubar processo do Client (Vite)
    if [ -n "$CLIENT_PID" ]; then
        echo -e "${RED}🔪 Encerrando Client WebGL (PID: $CLIENT_PID)...${NC}"
        kill $CLIENT_PID 2>/dev/null
    fi

    # Desligar todos os containers do docker-compose
    echo -e "${RED}🐳 Desligando infraestrutura Docker...${NC}"
    docker compose down

    echo -e "${GREEN}✅ Shutdown concluido com seguranca. Ate a proxima!${NC}"
    exit 0
}

# 4. Registrar o Trap para capturar sinais de termino (SIGINT / SIGTERM)
trap cleanup SIGINT SIGTERM

# 5. Iniciar o Frontend do Client Unity WebGL (em background para nao travar o terminal)
echo -e "${CYAN}----------------------------------------${NC}"
echo -e "${CYAN}🎮 Passo 4: Inicializando o Client Unity WebGL (Vite)...${NC}"

cd bombcrypto-client-v2/unity-web-template

echo -e "${CYAN}📦 Verificando dependencias do Client...${NC}"
npm install --silent > /dev/null 2>&1

echo -e "${GREEN}🚀 Iniciando Vite na porta 5174...${NC}"
npm run start --silent -- --port 5174 > /dev/null 2>&1 &
CLIENT_PID=$!

cd ../..

echo -e "${CYAN}----------------------------------------${NC}"
echo -e "${GREEN}   __  __ _____ ____    _   _____ ___  ____  ____    ${NC}"
echo -e "${GREEN}  |  \/  |  ___/ ___|  / \ |__  // _ \|  _ \|  _ \   ${NC}"
echo -e "${GREEN}  | |\/| | |_ | |  _  / _ \  / /| | | | |_) | | | |  ${NC}"
echo -e "${GREEN}  | |  | |  _|| |_| |/ ___ \/ /_| |_| |  _ <| |_| |  ${NC}"
echo -e "${GREEN}  |_|  |_|_|   \____/_/   \_\____\___/|_| \_\____/   ${NC}"
echo -e "${GREEN}                                                     ${NC}"
echo -e "${GREEN}                 O N L I N E                         ${NC}"
echo -e "${CYAN}----------------------------------------${NC}"
echo -e "${GREEN}🌐 Market Frontend: http://localhost:5173${NC}"
echo -e "${GREEN}🎮 Client WebGL:    http://localhost:5174${NC}"
echo -e "${CYAN}⚙️  Pressione Ctrl+C para desligar todo o ecossistema.${NC}"
echo -e "${CYAN}----------------------------------------${NC}"

# 6. Manter o terminal vivo aguardando o processo do Client
wait $CLIENT_PID
