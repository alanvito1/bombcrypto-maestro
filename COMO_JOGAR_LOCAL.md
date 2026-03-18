# 🐳 DEVOPS COMMANDER - MISSION CONTROL 🚀

## LOCAL PLAYABLE GUIDE - MEGAZORD BOOTSTRAP

Welcome, Founder! This document contains everything you need to know to securely spin up the entire Bomb Crypto V2 local ecosystem, log in to the test environment, and gracefully shut it down.

### 1. START THE ENGINE

To spin up the entire infrastructure (Databases, Redis, SmartFoxServer, APIs, Market, and the WebGL Unity Client), simply run the unified boot script from the root of the repository:

```bash
./start-megazord.sh
```

**What this does:**
- Populates all `.env` files across the repositories automatically.
- Mounts and runs the `first_user_add_data.sql` database seed.
- Triggers `docker compose up -d` to spin up the entire backend stack in isolated containers.
- Installs dependencies and natively launches the Unity WebGL client via Vite in the background on your host machine.

### 2. THE PATH TO PLAYABLE

Once the terminal prints `✅ MEGAZORD ONLINE!`, you can access the core components at the following local addresses:

- **🎮 Unity WebGL Client:** [http://localhost:5174](http://localhost:5174)
- **🌐 Marketplace Frontend:** [http://localhost:5173](http://localhost:5173)
- **⚙️ SFS Admin Dashboard (TCP/WSS):** `localhost:8080` (or `8443` for wss, `9933` for TCP)

### 3. TEST USER CREDENTIALS

To bypass the blockchain wallet login and dive straight into the Action, the `first_user_add_data.sql` script has injected a ready-to-play account populated with 3 Heroes, 1 House, and plenty of resources.

Use these credentials to login directly via the Client interface:

- **Username:** `testuser`
- **Password:** `111111`

*(This account's wallet is mock-mapped to `0x00` in the local configurations, and all API calls will use `http://localhost:8120` to validate this session).*

### 4. GRACEFUL SHUTDOWN (PREVENTING ZOMBIE PROCESSES)

When you're finished testing, **do not close the terminal window immediately.** Instead, return to the terminal running the script and press:

`Ctrl + C`

The built-in trap handler will detect the SIGINT signal and automatically:
1. Safely kill the Unity WebGL background Vite process.
2. Execute `docker compose down` to gracefully spin down the Postgres, Redis, and API containers.
3. Print `✅ Shutdown concluido com seguranca. Ate a proxima!` when everything is clean.