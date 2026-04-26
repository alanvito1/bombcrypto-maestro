# 🎮 Client Compilation and Execution Manual

This manual details how to correctly build the Unity WebGL Client locally and run it via its dedicated frontend wrapper, so it can connect to the local "Megazord" Server Infrastructure.

As the orchestrator now separates the Client from Docker, these steps guarantee maximum control and visibility over the build process.

## 1. Prerequisites

- Unity Editor (version 2021.3.x or as specified in `bombcrypto-client-v2`)
- WebGL Build Support installed in Unity
- Node.js (v22 recommended)

## 2. Compiling the WebGL Client

We do not compile the Unity project automatically via Docker because it relies on the local Unity Editor, which needs to be logged in and licensed.

**Steps:**
1. Open Unity Hub and Add/Open the project located at `bombcrypto-client-v2/` (Ensure the correct branch `dev/version2_1` is checked out, which the Megazord scripts enforce automatically).
2. Inside Unity, navigate to `File` -> `Build Settings`.
3. Select `WebGL` as the target platform.
4. Click `Build` (Do not click 'Build and Run').
5. You will be prompted for an output directory. You **must** select (or create) this exact path relative to the hub:
   `bombcrypto-client-v2/unity-web-template/public/webgl/build`

*Note: The frontend wrapper uses `.env.local` to point Vite to this specific folder (`VITE_UNITY_FOLDER=./webgl/build`).*

## 3. Running the Infrastructure (The Server)

Before starting the client, ensure the base infrastructure and backend services are running.

From the root (`/bomb`), run the Megazord:
**Mac/Linux:** `./scripts/start-megazord.sh`
**Windows:** `.\scripts\start-megazord.bat`

This will inject `.env.local` variables directly into the client repository so that the client points to the locally generated endpoints (AP_LOGIN_PORT, MARKET_API_PORT, etc.).

## 4. Executing the Client

Once the Unity WebGL build is finished and the infrastructure is up, you can start the client independently. We provide isolated scripts to perform this cleanly.

**Mac/Linux:**
```bash
./scripts/start-client.sh
```

**Windows:**
```cmd
.\scripts\start-client.bat
```

This script will:
1. Ensure the Node dependencies (`npm install`) are installed within the `unity-web-template` folder.
2. Start the Vite server, dynamically fetching the `CLIENT_VITE_PORT` (default 5176) configured in your Root Central Control Panel (`.env`).
3. Serve your local Unity build.

**Access the game via browser:**
```text
http://localhost:5176
```