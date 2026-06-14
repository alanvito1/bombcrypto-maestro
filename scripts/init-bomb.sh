#!/bin/bash

# Ensure running from root if script is directly executed
cd "$(dirname "$0")/.."

# ANSI Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}Creating the Central Control Panel at Root...${NC}"

if [ -f ".env.example" ] && [ ! -f ".env" ]; then
    echo -e "${GREEN}Creating root .env from .env.example${NC}"
    cp ".env.example" ".env"
else
    echo -e "${CYAN}Root .env already exists, skipping.${NC}"
fi

# Load variables to get the AP_LOGIN_PORT and CLIENT_VITE_PORT for the frontend trick
if [ -f ".env" ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

AP_PORT=${AP_LOGIN_PORT:-8120}

# Use Vite .env.local trick for Unity WebGL Client to bypass config conflicts
echo -e "${CYAN}Creating .env.local for Client with VITE_API_HOST and Unity config...${NC}"
mkdir -p bombcrypto-client-v2/unity-web-template
cat <<EOF > bombcrypto-client-v2/unity-web-template/.env.local
VITE_API_HOST="http://localhost:${AP_PORT}/web"
VITE_UNITY_FOLDER=./webgl/build
VITE_LOADER_URL_EXTENSION=/webgl.loader.js
VITE_DATA_URL_EXTENSION=/webgl.data
VITE_DATA_URL_MOBILE_EXTENSION=/mobile.data.br
VITE_FRAMEWORK_URL_EXTENSION=/webgl.framework.js
VITE_CODE_URL_EXTENSION=/webgl.wasm
EOF
echo -e "${GREEN}.env.local trick applied successfully.${NC}"

echo ""
echo -e "${CYAN}NOTE: All environment configurations are now managed exclusively in the root .env file!${NC}"
echo -e "${CYAN}There is no need to manually configure sub-repositories anymore.${NC}"
echo ""
echo -e "${GREEN}You can now start the environment via the start-megazord scripts.${NC}"
