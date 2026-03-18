# 🗺️ System Atlas (The Inventory)

This document contains the complete inventory of the DB tables, API Endpoints, and the Magic Numbers (Ports, Keys, Default Test Wallets) that map the entire Bomb Crypto V2 local ecosystem.

## 🔮 The Magic Numbers

These variables are shared across multiple `.env.example` configurations and are synchronized automatically by the `./init-bomb.sh` boot sequence.

| Magic Key / Secret | Value in Hub (`.env.example`) | Affected Sub-Repos | Description |
| :--- | :--- | :--- | :--- |
| `AP_LOGIN_TOKEN` / `JWT_BEARER_SECRET` / `JWT_LOGIN_SECRET` | `your_server_login_token` / `your_client_login_token` | `server-v2`, `market-v2` | Token used to authenticate Server-to-API and Client-to-API sessions securely. |
| `AES_SECRET` / `GAME_SIGN_PADDING` / `DAPP_SIGN_PADDING` | `(empty by default)` | `server-v2`, `client-v2` | Secrets used by Unity Client and AP-Login to obfuscate payloads. |
| DB Connection String | `postgres://postgres:123456@localhost:5432/bombcrypto2` | All Backend APIs | Standardized PostgreSQL connection matching `docker-compose.yml`. |
| Redis Connection String | `redis://@localhost:6379/0` | All Backend APIs | Standardized Redis connection matching `docker-compose.yml`. |

### Default Test Wallet

- **Username**: `testuser`
- **Password**: `111111`
- **Mapped Wallet**: `0x00` (Defined implicitly via `first_user_add_data.sql` and mapped natively by local login scripts).

---

## 🚪 API Endpoints Mapping

### Authentication (AP-Login - `8120`)

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `POST` | `/login` | Authenticates User Credentials (`testuser`) |
| `GET` | `/account/forgot/change?token=` | Reset Password Link Endpoint |

### SmartFox Game Server (`8080`, `8443`, `9933`)

| Type | Port | Description |
| :--- | :--- | :--- |
| TCP/UDP | `9933` | Primary Game Socket (Real-time syncing) |
| HTTP | `8080` | Client connection and fallback |
| WSS | `8443` | Secure Websocket connection |

### Marketplace (AP-Market - `9120` & Market API - `3000`/`3003`)

| Type | Port | Description |
| :--- | :--- | :--- |
| AP-Market | `9120` | Handles market listings and integration to backend DB |
| Market API | `3000` | REST API for Market Frontend interactions |
| Blockchain Center | `3003` | Interacts with smart contracts / Hardhat |

---

## 🗄️ Database Entity-Relationship Diagram (ERD)

The following ER Diagram illustrates the primary tables populated by `first_user_add_data.sql` and `schema.sql`.

```mermaid
erDiagram
    "user" ||--o{ user_bomber : owns
    "user" ||--o{ user_house : owns
    "user" ||--o{ user_block_reward : has_currencies

    "user" {
        int id_user PK
        string user_name "UNIQUE"
        string email "UNIQUE"
        string second_username "UNIQUE"
    }

    user_bomber {
        int uid FK "User ID"
        string gen_id "Blockchain Hash"
        int bomber_id "Hero ID"
        int level
        int power
        int bomb_range
        int stamina
        int speed
        int bomb
        string ability "JSON Array"
        int charactor
        int color
        int rare
        int bomb_skin
        int energy
        int stage
        datetime time_rest
        int active
        int hasDelete
        int random
        string shield "JSON Array"
        string ability_shield "JSON Array"
        int is_reset
        int shield_level
        string type "BSC"
        string data_type "HERO"
        string hero_tr_type
        int stake_amount
        int stake_sen
        datetime create_at
    }

    user_house {
        int uid FK "User ID"
        string gen_house_id "Blockchain Hash"
        int house_id
        int rarity
        int recovery
        int max_bomber
        int active
        datetime sync_date
        string type "BSC"
        datetime create_at
        datetime end_time_rent
    }

    user_block_reward {
        int uid FK "User ID"
        string reward_type "GOLD, SENSPARK, BCOIN, COIN, ROCK, GEM_LOCKED, GEM"
        float values
        float total_values
        string type "TR, BSC"
    }
```