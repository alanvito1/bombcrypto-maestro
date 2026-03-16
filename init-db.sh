#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE backend;
    CREATE DATABASE bombcrypto2;
EOSQL

echo "Importing schemas to bombcrypto2..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "bombcrypto2" -f /docker-entrypoint-initdb.d/server-db/schema.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "bombcrypto2" -f /docker-entrypoint-initdb.d/server-db/init.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "bombcrypto2" -f /docker-entrypoint-initdb.d/server-db/pvp_season_1.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "bombcrypto2" -f /docker-entrypoint-initdb.d/server-db/first_user_add_data.sql
echo "Databases initialized successfully."
