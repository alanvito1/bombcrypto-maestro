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
echo -e "${WHITE}[AVRE] 🔧 Passo 2: Configurando variaveis de ambiente na raiz (Central Control Panel)...${NC}"
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

# Load port variables to display later
if [ -f ".env" ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

FRONTEND_PORT=${MARKET_FRONTEND_PORT:-5175}

# 3. Subir infraestrutura Base (Bancos, Hardhat, Server, Market, etc)
echo -e "${RED}----------------------------------------${NC}"
echo -e "${WHITE}[AVRE] 🐳 Passo 3: Subindo containers Docker...${NC}"
docker compose up -d

echo -e "${RED}----------------------------------------${NC}"
echo -e "${RED}[AVRE] ❤️ Orchestration successful${NC}"
echo -e "${RED}----------------------------------------${NC}"
echo -e "${WHITE}🌐 Base Infrastructure Started!${NC}"
echo -e "${WHITE}🌐 Market Frontend (if enabled): http://localhost:${FRONTEND_PORT}${NC}"
echo -e "${WHITE}🎮 Note: The Unity WebGL client is separate. Please check /docs/CLIENT_COMPILATION_MANUAL.md for instructions.${NC}"
echo -e "${WHITE}🎮 Start the client with: ./scripts/start-client.sh${NC}"
echo -e "${RED}----------------------------------------${NC}"
