#!/bin/bash
set -e

# 1. Create databases
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE market;
    CREATE DATABASE bombcrypto;
    CREATE DATABASE bombcrypto2;
EOSQL

echo ">>> Databases created successfully."

# 2. Apply Market Schema
echo ">>> Applying Market schema..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "market" < /submodules/market/db/schema.sql

# 3. Apply Server Schema
echo ">>> Applying Game Server schema..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "bombcrypto" < /submodules/server/server/db/schema.sql

# 4. Apply Login Schema
echo ">>> Applying Login API schema..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "bombcrypto2" < /submodules/server/api/login/db/schema.sql

echo ">>> All schemas applied successfully."
