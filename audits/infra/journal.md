# 📓 Scribe's Journal: Technical Risks & Observations

This document logs anomalies, ambiguities, and technical risks found in Senspark's codebase during the architectural mapping of the Bomb Crypto V2 local environment. Our goal is to catalog these issues so we can tackle them systematically.

---

## 1. 🔑 Hardcoded Secrets & Magic Strings

**The Risk:** Senspark's architecture heavily relies on shared magic strings (`JWT_BEARER_SECRET`, `AP_LOGIN_TOKEN`, `AES_SECRET`) scattered across multiple backend APIs (`ap-login`, `ap-market`, `sfs-game-1`).

**Why it matters:**
Currently, the `init-bomb.sh` script blindly copies `.env.example` to `.env`. If a developer modifies a secret in one repository without manually updating the others, the ecosystem will experience a cascading failure. For example, if the `SmartFoxServer` expects a different `AP_LOGIN_TOKEN` than what the Client was issued by `AP-Login`, authentication will silently fail.

**Proposed Mitigation:**
The `start-megazord.sh` or a future bootstrapper should dynamically inject a single source of truth for these secrets into all sub-repositories at boot time, overriding any mismatched local configurations.

---

## 2. 🎮 Manual WebGL Build Dependency

**The Risk:** The `bombcrypto-client-v2/unity-web-template` currently relies on a manual Unity WebGL build process. The `vite` dev server (`npm run start`) will fail to serve the game properly if the developer has not successfully built the WebGL project via the Unity Editor first.

**Why it matters:**
This breaks the "One-Click Boot" philosophy. A new developer cloning the Hub cannot simply run `docker compose up -d` and start playing; they must install Unity, open the client project, and trigger a build.

**Proposed Mitigation:**
Document this strict prerequisite loudly in the `README.md` and `COMO_JOGAR_LOCAL.md`. Eventually, consider setting up a pipeline that fetches a pre-compiled `webgl-build` artifact from a remote storage for local testing, bypassing the Unity Editor requirement entirely.

---

## 3. ⛓️ Hardhat Contract Deployment Sync

**The Risk:** The `hardhat-node` container successfully boots a local Ethereum chain on port `8545`. However, there is no automated script that deploys the required OpenZeppelin BHero/BHouse smart contracts and injects their newly generated contract addresses back into the `bombcrypto-market-v2` ecosystem.

**Why it matters:**
While `first_user_add_data.sql` mocks the database, any marketplace operations (buying/selling) or synchronization events (listening to blocks in `detect-transfer`) will fail because the backend APIs expect specific contract addresses (e.g., `0x30cc0...`) that do not exist on the fresh local chain.

**Proposed Mitigation:**
Create a dedicated `deploy-megazord.sh` script that:
1. Waits for `8545` to be healthy.
2. Runs `npx hardhat run scripts/deploy.js --network localhost` within the `hardhat-node` container.
3. Automatically overwrites `BCOIN_CONTRACT_ADDRESS` and `SEN_CONTRACT_ADDRESS` in the `.env` of the Market API.

---

## 4. 🗄️ Database Seeds and UID Mapping

**The Risk:** The database seed script (`first_user_add_data.sql`) successfully injects `user_bomber` and `user_house` for `uid=1`. The local client bypasses wallet signatures by natively mapping `testuser` to Wallet `0x00`.

**Why it matters:**
If a developer accidentally connects their real MetaMask to the local client, or attempts to register a new user, the mock mapping breaks.

**Proposed Mitigation:**
Keep the login mock strictly isolated to local testing. Instruct developers in `CONTRIBUTING.md` not to use real wallet browser extensions while testing against `localhost:5174`.