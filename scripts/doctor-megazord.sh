#!/bin/bash

# Vai para o root do projeto
cd "$(dirname "$0")/.."

echo "=========================================================="
echo "🩺 MEGAZORD DOCTOR: Health Diagnostics & Pre-Flight Checks 🩺"
echo "=========================================================="
echo ""

if [ -f ".env" ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

# Gather ports dynamically or fallback
DB_PORT=${POSTGRES_PORT:-5433}
REDIS_P=${REDIS_PORT:-6380}
HARDHAT_P=${HARDHAT_PORT:-8546}
AP_LOGIN_P=${AP_LOGIN_PORT:-8121}
AP_MARKET_P=${AP_MARKET_PORT:-9121}
MARKET_API_P=${MARKET_API_PORT:-3001}
BC_CENTER_P=${BLOCKCHAIN_CENTER_PORT:-3004}
SFS_HTTP_P=${SFS_HTTP_PORT:-8081}
SFS_HTTPS_P=${SFS_HTTPS_PORT:-8444}
SFS_TCP_P=${SFS_TCP_PORT:-9934}
FRONTEND_P=${MARKET_FRONTEND_PORT:-5175}
CLIENT_P=${CLIENT_VITE_PORT:-5176}

# Ports to check before starting
PORTS_TO_CHECK=($DB_PORT $REDIS_P $HARDHAT_P $AP_LOGIN_P $AP_MARKET_P $MARKET_API_P $BC_CENTER_P $SFS_HTTP_P $SFS_HTTPS_P $SFS_TCP_P $FRONTEND_P $CLIENT_P)

echo "🔍 PRE-FLIGHT: Checking for occupied ports..."
OCCUPIED_PORTS=0

for port in "${PORTS_TO_CHECK[@]}"; do
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null; then
        echo "❌ ALERT: Port $port is already in use!"
        OCCUPIED_PORTS=$((OCCUPIED_PORTS + 1))
    fi
done

if [ $OCCUPIED_PORTS -gt 0 ]; then
    echo ""
    echo "⚠️  WARNING: Found $OCCUPIED_PORTS occupied ports."
    echo "💡 TIP: Run './scripts/clean-megazord.sh' to terminate zombie processes before starting the Megazord."
else
    echo "✅ ALL CLEAR: All essential ports are free."
fi

echo ""
echo "🐳 POST-BOOT: Checking Docker Container Health..."

if ! docker info > /dev/null 2>&1; then
  echo "❌ ERROR: Docker daemon is not running. Please start Docker."
  exit 1
fi

UP_CONTAINERS=$(docker ps | grep 'Up' | grep 'bombcrypto')
if [ -z "$UP_CONTAINERS" ]; then
    echo "⚠️  WARNING: No running BombCrypto Docker containers found."
    echo "💡 TIP: Run './scripts/start-megazord.sh' to boot the ecosystem."
else
    echo "✅ RUNNING CONTAINERS DETECTED:"
    echo "$UP_CONTAINERS" | awk '{print "   - " $NF}'
fi

echo ""
echo "🩺 Diagnosis complete."
