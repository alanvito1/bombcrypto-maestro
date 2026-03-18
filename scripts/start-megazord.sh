#!/bin/bash

# 🌹 SECURITY GATEKEEPER
# Guard: AVRE
# -------------------------
# Identity verification layer.

# ANSI Colors (AVRE Palette)
WHITE='\033[1;37m'
RED='\033[1;31m'
DIM_RED='\033[0;31m'
NC='\033[0m' # No Color

# ==========================================
# 🌹 AVRE INITIATION SEQUENCE
# ==========================================
echo -e "${RED}==========================================${NC}"
echo -e "${WHITE}    db    Y88b  /  88888b  888888 ${NC}"
echo -e "${WHITE}   dPYb    Y88 /   88   88 88__   ${NC}"
echo -e "${WHITE}  dP__Yb    Y8/    88   88 88\"\"   ${NC}"
echo -e "${WHITE} dP\"\"\"\"Yb    Y     88888P  888888 ${NC}"
echo -e "${RED}==========================================${NC}"
echo -e "${WHITE}[AVRE] 🌹 System active...${NC}"
echo -e "${WHITE}[AVRE] 🌹 Iniciando a sequencia de boot do ecossistema Bomb Crypto V2...${NC}"

# Vai para o root do projeto garantindo que funcione de qualquer pasta
cd "$(dirname "$0")/.."

# 1. Sincronizar sub-repositorios (Pre-Flight Sync)
echo -e "${RED}----------------------------------------${NC}"
echo -e "${WHITE}[AVRE] 🔄 Passo 1: Sincronizando Sub-repositorios (Pre-Flight Sync)...${NC}"

REPOS=("bombcrypto-client-v2" "bombcrypto-server-v2" "bombcrypto-market-v2")

for repo in "${REPOS[@]}"; do
    if [ -d "$repo" ]; then
        echo -e "${WHITE}[AVRE] 📂 Verificando $repo...${NC}"
        cd "$repo" || continue

        # 🐙 FAIL-SAFE GIT SYNC: Clean any uncommitted changes or untracked files
        git checkout .
        git clean -fd

        if [ "$repo" = "bombcrypto-client-v2" ]; then
            git fetch
            git checkout dev/version2_1

            git pull origin dev/version2_1
            if [ $? -ne 0 ]; then
                echo -e "${DIM_RED}[AVRE] 🥀 Check this... Sync failed in $repo.${NC}"
                while true; do
                    read -p "Abort boot or Continue with local changes? (A/C): " choice
                    case "$choice" in
                        [Aa]* ) echo -e "${RED}[AVRE] 🛑 Boot abortado.${NC}"; exit 1;;
                        [Cc]* ) echo -e "${WHITE}[AVRE] ❤️ Continuando com as alteracoes locais...${NC}"; break;;
                        * ) echo -e "${WHITE}[AVRE] Por favor, responda A ou C.${NC}";;
                    esac
                done
            else
                echo -e "${RED}[AVRE] ❤️ $repo sincronizado.${NC}"
            fi
        else
            # Tentar checkout na main, se falhar tenta na master
            git checkout main
            if [ $? -ne 0 ]; then
                git checkout master
            fi

            # Tentar pull
            git pull
            if [ $? -ne 0 ]; then
                echo -e "${DIM_RED}[AVRE] 🥀 Check this... Sync failed in $repo.${NC}"
                while true; do
                    read -p "Abort boot or Continue with local changes? (A/C): " choice
                    case "$choice" in
                        [Aa]* ) echo -e "${RED}[AVRE] 🛑 Boot abortado.${NC}"; exit 1;;
                        [Cc]* ) echo -e "${WHITE}[AVRE] ❤️ Continuando com as alteracoes locais...${NC}"; break;;
                        * ) echo -e "${WHITE}[AVRE] Por favor, responda A ou C.${NC}";;
                    esac
                done
            else
                echo -e "${RED}[AVRE] ❤️ $repo sincronizado.${NC}"
            fi
        fi

        cd ..
    else
        echo -e "${DIM_RED}[AVRE] 🥀 Diretorio $repo nao encontrado, pulando...${NC}"
    fi
done

# 2. Configurar variaveis de ambiente (.env)
echo -e "${RED}----------------------------------------${NC}"
echo -e "${WHITE}[AVRE] 🔧 Passo 2: Configurando variaveis de ambiente...${NC}"
./scripts/init-bomb.sh

# 2.5 Fix CRLF line endings on Server Deploy scripts for Windows compatibility
echo -e "${RED}----------------------------------------${NC}"
echo -e "${WHITE}[AVRE] 🐧 Passo 2.5: Corrigindo quebras de linha (CRLF para LF) nos scripts do servidor...${NC}"
if [ -d "bombcrypto-server-v2/server/deploy" ]; then
    if sed --version >/dev/null 2>&1; then
        find bombcrypto-server-v2/server/deploy -type f -name "*.sh" -exec sed -i 's/\r$//' {} +
    else
        find bombcrypto-server-v2/server/deploy -type f -name "*.sh" -exec sed -i '' 's/\r$//' {} +
    fi
    echo -e "${RED}[AVRE] ❤️ Scripts .sh do servidor convertidos para formato Linux.${NC}"
else
    echo -e "${DIM_RED}[AVRE] 🥀 Diretorio de deploy do servidor não encontrado, pulando...${NC}"
fi

# 3. Subir infraestrutura Base (Bancos, Hardhat, Server, Market, etc)
echo -e "${RED}----------------------------------------${NC}"
echo -e "${WHITE}[AVRE] 🐳 Passo 3: Subindo containers Docker...${NC}"
docker compose up -d

# Funcao de Graceful Shutdown
cleanup() {
    echo ""
    echo -e "${DIM_RED}[AVRE] 🛑 Detectado sinal de interrupcao (Ctrl+C). Iniciando Graceful Shutdown...${NC}"

    # Derrubar processo do Client (Vite)
    if [ -n "$CLIENT_PID" ]; then
        echo -e "${RED}[AVRE] 🔪 Encerrando Client WebGL (PID: $CLIENT_PID)...${NC}"
        kill $CLIENT_PID 2>/dev/null
    fi

    # Desligar todos os containers do docker-compose
    echo -e "${RED}[AVRE] 🐳 Desligando infraestrutura Docker...${NC}"
    docker compose down

    echo -e "${WHITE}[AVRE] ❤️ Shutdown concluido com seguranca. Ate a proxima!${NC}"
    exit 0
}

# 4. Registrar o Trap para capturar sinais de termino (SIGINT / SIGTERM)
trap cleanup SIGINT SIGTERM

# 5. Iniciar o Frontend do Client Unity WebGL (em background para nao travar o terminal)
echo -e "${RED}----------------------------------------${NC}"
echo -e "${WHITE}[AVRE] 🎮 Passo 4: Inicializando o Client Unity WebGL (Vite)...${NC}"

cd bombcrypto-client-v2/unity-web-template

echo -e "${WHITE}[AVRE] 📦 Verificando dependencias do Client...${NC}"
npm install --silent > /dev/null 2>&1

echo -e "${RED}[AVRE] ❤️ Iniciando Vite na porta 5174...${NC}"
npm run start --silent -- --port 5174 > /dev/null 2>&1 &
CLIENT_PID=$!

cd ../..

echo -e "${RED}----------------------------------------${NC}"
echo -e "${RED}[AVRE] ❤️ Build successful${NC}"
echo -e "${RED}----------------------------------------${NC}"
echo -e "${WHITE}🌐 Market Frontend: http://localhost:5173${NC}"
echo -e "${WHITE}🎮 Client WebGL:    http://localhost:5174${NC}"
echo -e "${RED}⚙️  Pressione Ctrl+C para desligar todo o ecossistema.${NC}"
echo -e "${RED}----------------------------------------${NC}"

# 6. Manter o terminal vivo aguardando o processo do Client
wait $CLIENT_PID
