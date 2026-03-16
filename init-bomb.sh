#!/bin/bash

echo "Copying .env.example files to .env where .env is missing..."
find . -type f -name ".env.example" | while read -r example; do
    env="${example%.example}"
    if [ ! -f "$env" ]; then
        echo "Creating $env"
        cp "$example" "$env"
    else
        echo "$env already exists, skipping."
    fi
done

echo ""
echo "NOTE: Ensure all Blockchain RPC URLs in your .env files are pointed to:"
echo "http://bombcrypto-hardhat:8545 (or http://localhost:8545 locally)"
echo "and DB connection strings use 'postgres' and 'redis' instead of localhost!"
echo ""
echo "You can now start the environment with:"
echo "docker compose up -d"
