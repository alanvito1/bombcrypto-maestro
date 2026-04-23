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

echo -e "${RED}==========================================================${NC}"
echo -e "${WHITE}[AVRE] 🌹 TERRA ARRASADA: Cleaning up the Megazord Environment...${NC}"
echo -e "${RED}==========================================================${NC}"
echo ""

# Vai para o root do projeto
cd "$(dirname "$0")/.."

# 1. Bring down docker compose with volumes
echo -e "${WHITE}[AVRE] 🐳 Stopping Docker containers and removing volumes...${NC}"
docker compose down -v

if [ -f ".env" ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

FRONTEND_PORT=${MARKET_FRONTEND_PORT:-5175}
CLIENT_PORT=${CLIENT_VITE_PORT:-5176}

# 2. Kill zombie processes on port (Market Frontend)
echo -e "${WHITE}[AVRE] 🌐 Killing Zombie Market Frontend processes (Vite) on port ${FRONTEND_PORT}...${NC}"
MARKET_PID=$(lsof -t -i :${FRONTEND_PORT} -sTCP:LISTEN)
if [ -n "$MARKET_PID" ]; then
    kill -9 $MARKET_PID
    echo -e "${RED}[AVRE] ❤️ Killed process $MARKET_PID.${NC}"
else
    echo -e "${DIM_RED}[AVRE] 🥀 No zombie process found on port ${FRONTEND_PORT}.${NC}"
fi

# 3. Kill zombie processes on port (Unity WebGL Client)
echo -e "${WHITE}[AVRE] 🎮 Killing Zombie Unity WebGL Client processes (Vite) on port ${CLIENT_PORT}...${NC}"
CLIENT_PID=$(lsof -t -i :${CLIENT_PORT} -sTCP:LISTEN)
if [ -n "$CLIENT_PID" ]; then
    kill -9 $CLIENT_PID
    echo -e "${RED}[AVRE] ❤️ Killed process $CLIENT_PID.${NC}"
else
    echo -e "${DIM_RED}[AVRE] 🥀 No zombie process found on port ${CLIENT_PORT}.${NC}"
fi

# General safety check with pkill to terminate any node or vite instances
echo -e "${WHITE}[AVRE] 🔄 Running general cleanup for Vite and Node processes...${NC}"
pkill -f 'vite'
pkill -f 'npm run start'

echo ""
echo -e "${RED}[AVRE] ❤️ CLEANUP COMPLETE: Environment is clean and ready for a fresh start.${NC}"
echo -e "${WHITE}[AVRE] 💡 NOTE: .env files were not deleted.${NC}"
