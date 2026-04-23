#!/bin/bash

# Ensure running from root if script is directly executed
cd "$(dirname "$0")/.."

# ANSI Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

if [ -f ".env" ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi
PORT=${CLIENT_VITE_PORT:-5176}

WRAPPER_DIR="bombcrypto-client-v2/unity-web-template"

echo -e "${CYAN}Changing directory to ${WRAPPER_DIR}...${NC}"
cd "$WRAPPER_DIR" || exit

if [ ! -d "node_modules" ]; then
    echo -e "${CYAN}Missing node_modules. Running npm install...${NC}"
    npm install
fi

echo -e "${GREEN}Starting Vite server on port ${PORT}...${NC}"
npm run start -- --port $PORT --host 0.0.0.0