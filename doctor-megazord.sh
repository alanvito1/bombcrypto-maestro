#!/bin/bash

echo "=========================================================="
echo "🩺 MEGAZORD DOCTOR: Health Diagnostics & Pre-Flight Checks 🩺"
echo "=========================================================="
echo ""

# Ports to check before starting
PORTS_TO_CHECK=(5432 6379 8545 8120 9120 3000 3003 8080 8443 9933 5173 5174)

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
    echo "💡 TIP: Run './clean-megazord.sh' to terminate zombie processes before starting the Megazord."
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
    echo "💡 TIP: Run './start-megazord.sh' to boot the ecosystem."
else
    echo "✅ RUNNING CONTAINERS DETECTED:"
    echo "$UP_CONTAINERS" | awk '{print "   - " $NF}'
fi

echo ""
echo "🩺 Diagnosis complete."
