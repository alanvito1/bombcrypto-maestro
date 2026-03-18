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

# 2. Kill zombie processes on port 5173 (Market Frontend)
echo -e "${WHITE}[AVRE] 🌐 Killing Zombie Market Frontend processes (Vite) on port 5173...${NC}"
MARKET_PID=$(lsof -t -i :5173 -sTCP:LISTEN)
if [ -n "$MARKET_PID" ]; then
    kill -9 $MARKET_PID
    echo -e "${RED}[AVRE] ❤️ Killed process $MARKET_PID.${NC}"
else
    echo -e "${DIM_RED}[AVRE] 🥀 No zombie process found on port 5173.${NC}"
fi

# 3. Kill zombie processes on port 5174 (Unity WebGL Client)
echo -e "${WHITE}[AVRE] 🎮 Killing Zombie Unity WebGL Client processes (Vite) on port 5174...${NC}"
CLIENT_PID=$(lsof -t -i :5174 -sTCP:LISTEN)
if [ -n "$CLIENT_PID" ]; then
    kill -9 $CLIENT_PID
    echo -e "${RED}[AVRE] ❤️ Killed process $CLIENT_PID.${NC}"
else
    echo -e "${DIM_RED}[AVRE] 🥀 No zombie process found on port 5174.${NC}"
fi

# General safety check with pkill to terminate any node or vite instances
echo -e "${WHITE}[AVRE] 🔄 Running general cleanup for Vite and Node processes...${NC}"
pkill -f 'vite'
pkill -f 'npm run start'

echo ""
echo -e "${RED}[AVRE] ❤️ CLEANUP COMPLETE: Environment is clean and ready for a fresh start.${NC}"
echo -e "${WHITE}[AVRE] 💡 NOTE: .env files were not deleted.${NC}"
