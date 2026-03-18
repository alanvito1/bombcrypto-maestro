#!/bin/bash

# Ensure running from root if script is directly executed
cd "$(dirname "$0")/.."

# ANSI Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}Copying .env template files to .env where .env is missing...${NC}"

# Strict list of directories
DIRS=(
    "bombcrypto-client-v2/unity-web-template"
    "bombcrypto-server-v2/api/login"
    "bombcrypto-server-v2/api/market"
    "bombcrypto-server-v2/server"
    "bombcrypto-market-v2/frontend"
    "bombcrypto-market-v2/backend"
    "bombcrypto-market-v2/detect-transfer"
    "."
)

for dir in "${DIRS[@]}"; do
    if [ -d "$dir" ] || [ "$dir" = "." ]; then
        if [ -f "$dir/.env.example" ]; then
            if [ ! -f "$dir/.env" ]; then
                echo -e "${GREEN}Creating $dir/.env from .env.example${NC}"
                cp "$dir/.env.example" "$dir/.env"
            else
                echo -e "${CYAN}$dir/.env already exists, skipping.${NC}"
            fi
        elif [ -f "$dir/.env.sample" ]; then
            if [ ! -f "$dir/.env" ]; then
                echo -e "${GREEN}Creating $dir/.env from .env.sample${NC}"
                cp "$dir/.env.sample" "$dir/.env"
            else
                echo -e "${CYAN}$dir/.env already exists, skipping.${NC}"
            fi
        fi
    fi
done

# Inject VITE_API_HOST into client .env
CLIENT_ENV="bombcrypto-client-v2/unity-web-template/.env"
if [ -f "$CLIENT_ENV" ]; then
    echo -e "${CYAN}Injecting VITE_API_HOST into $CLIENT_ENV...${NC}"
    # Replace the host using sed (macOS and Linux compatible)
    if sed --version >/dev/null 2>&1; then
        # GNU sed
        sed -i 's|VITE_API_HOST="your-api-host"|VITE_API_HOST="http://localhost:8120"|g' "$CLIENT_ENV"
    else
        # BSD sed (macOS)
        sed -i '' 's|VITE_API_HOST="your-api-host"|VITE_API_HOST="http://localhost:8120"|g' "$CLIENT_ENV"
    fi
    echo -e "${GREEN}Injection complete.${NC}"
fi

# Apply Hotfixes to Backend .env files
echo -e "${CYAN}Applying Runtime Hotfixes to Backend .env files...${NC}"

BACKEND_DIRS=(
    "bombcrypto-server-v2/api/login"
    "bombcrypto-server-v2/api/market"
    "bombcrypto-server-v2/server"
    "bombcrypto-market-v2/backend"
    "bombcrypto-market-v2/detect-transfer"
)

for dir in "${BACKEND_DIRS[@]}"; do
    ENV_FILE="$dir/.env"
    if [ -f "$ENV_FILE" ]; then
        echo -e "${CYAN}Patching $ENV_FILE...${NC}"
        if sed --version >/dev/null 2>&1; then
            # GNU sed
            sed -i 's/OBFUSCATE_BYTES_APPEND=""/OBFUSCATE_BYTES_APPEND=0/g' "$ENV_FILE"
            sed -i 's/DB_HOST="*127\.0\.0\.1"*/DB_HOST="postgres"/g' "$ENV_FILE"
            sed -i 's/DB_HOST="*localhost"*/DB_HOST="postgres"/g' "$ENV_FILE"
            sed -i 's/DATABASE_URL="*postgresql:\/\/[^:]*:[^@]*@127\.0\.0\.1/DATABASE_URL="postgresql:\/\/postgres:postgres@postgres/g' "$ENV_FILE"
            sed -i 's/DATABASE_URL="*postgresql:\/\/[^:]*:[^@]*@localhost/DATABASE_URL="postgresql:\/\/postgres:postgres@postgres/g' "$ENV_FILE"
            sed -i 's/REDIS_HOST="*127\.0\.0\.1"*/REDIS_HOST="redis"/g' "$ENV_FILE"
            sed -i 's/REDIS_HOST="*localhost"*/REDIS_HOST="redis"/g' "$ENV_FILE"
        else
            # BSD sed
            sed -i '' 's/OBFUSCATE_BYTES_APPEND=""/OBFUSCATE_BYTES_APPEND=0/g' "$ENV_FILE"
            sed -i '' 's/DB_HOST="*127\.0\.0\.1"*/DB_HOST="postgres"/g' "$ENV_FILE"
            sed -i '' 's/DB_HOST="*localhost"*/DB_HOST="postgres"/g' "$ENV_FILE"
            sed -i '' 's/DATABASE_URL="*postgresql:\/\/[^:]*:[^@]*@127\.0\.0\.1/DATABASE_URL="postgresql:\/\/postgres:postgres@postgres/g' "$ENV_FILE"
            sed -i '' 's/DATABASE_URL="*postgresql:\/\/[^:]*:[^@]*@localhost/DATABASE_URL="postgresql:\/\/postgres:postgres@postgres/g' "$ENV_FILE"
            sed -i '' 's/REDIS_HOST="*127\.0\.0\.1"*/REDIS_HOST="redis"/g' "$ENV_FILE"
            sed -i '' 's/REDIS_HOST="*localhost"*/REDIS_HOST="redis"/g' "$ENV_FILE"
        fi
    fi
done
echo -e "${GREEN}Hotfixes applied.${NC}"

echo ""
echo -e "${CYAN}NOTE: Ensure all Blockchain RPC URLs in your .env files are pointed to:${NC}"
echo -e "${CYAN}http://bombcrypto-hardhat:8545 (or http://localhost:8545 locally)${NC}"
echo -e "${CYAN}and DB connection strings use 'postgres' and 'redis' instead of localhost!${NC}"
echo ""
echo -e "${GREEN}You can now start the environment with:${NC}"
echo -e "${GREEN}docker compose up -d${NC}"
