#!/bin/bash

echo "=========================================================="
echo "🧹 TERRA ARRASADA: Cleaning up the Megazord Environment 🧹"
echo "=========================================================="
echo ""

# Vai para o root do projeto
cd "$(dirname "$0")/.."

# 1. Bring down docker compose with volumes
echo "🐳 Stopping Docker containers and removing volumes..."
docker compose down -v

# 2. Kill zombie processes on port 5173 (Market Frontend)
echo "🌐 Killing Zombie Market Frontend processes (Vite) on port 5173..."
MARKET_PID=$(lsof -t -i :5173 -sTCP:LISTEN)
if [ -n "$MARKET_PID" ]; then
    kill -9 $MARKET_PID
    echo "✅ Killed process $MARKET_PID."
else
    echo "ℹ️  No zombie process found on port 5173."
fi

# 3. Kill zombie processes on port 5174 (Unity WebGL Client)
echo "🎮 Killing Zombie Unity WebGL Client processes (Vite) on port 5174..."
CLIENT_PID=$(lsof -t -i :5174 -sTCP:LISTEN)
if [ -n "$CLIENT_PID" ]; then
    kill -9 $CLIENT_PID
    echo "✅ Killed process $CLIENT_PID."
else
    echo "ℹ️  No zombie process found on port 5174."
fi

# General safety check with pkill to terminate any node or vite instances
echo "🔄 Running general cleanup for Vite and Node processes (optional but recommended for complete Terra Arrasada)..."
pkill -f 'vite'
pkill -f 'npm run start'

echo ""
echo "✅ CLEANUP COMPLETE: Environment is clean and ready for a fresh start."
echo "💡 NOTE: .env files were not deleted."
