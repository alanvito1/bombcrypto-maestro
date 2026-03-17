# 🐞 EXTERMINATOR AUDIT REPORT: RPC, Login Flow, and Gas Pricing (Phase 2)

## THE TRAJECTORY (Diagnostic Mapping)

### 1. RPC Handling & Login Flow

#### A. Client (Unity WebGL / C# & TypeScript)
*   **RPC Definitions:**
    *   Defined in `bombcrypto-client-v2/unity-web-template/src/controllers/RpcNetworkUtils.ts`.
    *   Polygon Mainnet RPC: `https://polygon-mainnet.infura.io/` (Single URL)
    *   Polygon Amoy Testnet RPC: `https://rpc-amoy.polygon.technology/` (Single URL)
    *   In `bombcrypto-client-v2/unity-web-template/src/controllers/BlockChain/Module/RpcToken/RpcAddress.ts`, there are multiple fallback URLs for BSC, but for Polygon Mainnet it has ONLY ONE: `https://polygon-rpc.com/`. Polygon Testnet ONLY ONE: `https://rpc-amoy.polygon.technology/`.
*   **RPC Fallback Mechanism:**
    *   The client uses a rudimentary `getAllRpc` and `shuffle` mechanism (`unity-web-template/src/controllers/BlockChain/Module/Utils/RpcTokens.ts`), but because Polygon only has one URL defined in the arrays, **no fallback occurs if the primary RPC fails or drops the connection.**

#### B. Server (Kotlin / SmartFoxServer)
*   **Login Verification Flow:**
    *   The logic resides in `bombcrypto-server-v2/server/BombChainExtension/src/com/senspark/game/api/AuthApi.kt`.
    *   `verifyAuth(username: String, token: String, dataType: EnumConstants.DataType)` sends a POST request to an external `ap-login` service.
    *   `polVerifyLoginUrl` is determined by `AP_LOGIN` (e.g., `http://ap-login/web/pol/verify`).
*   **RPC Handling on Server:**
    *   The `server-v2` itself delegates the actual Web3 signature verification to the `ap-login` microservice (which is external to this specific codebase/repo block, likely running as a separate Docker container in production).
    *   If `ap-login`'s Polygon RPC drops, the `verifyAuth` API call likely times out or receives a 5xx error, throwing an exception back to `UserLoginHandler.kt`/`BnbLoginManager.kt`, failing the authentication process.

#### C. Market (React / TypeScript)
*   **RPC Definitions:**
    *   Defined via JSON config in `bombcrypto-market-v2/frontend/src/utils/constant/Address.Polygon.Prod.json` as a single string: `"rpc": "https://polygon-rpc.com"`.
    *   Loaded into `config.ts` (`RPC_BSC.Polygon`).
*   **RPC Fallback Mechanism:**
    *   There is no active fallback array mechanism visible in the frontend market `config.ts`. It strictly relies on the single RPC endpoint loaded from the JSON.
    *   The backend API `bombcrypto-market-v2/blockchain-center-api` DOES have an advanced `rpcManager` (handling arrays, cooldowns, stats), but the Frontend UI and Client Game do NOT.

### 2. Gas Price Calculation

#### A. Client (Unity WebGL / TypeScript Bridge)
*   **Gas Estimation Logic:**
    *   Located in `bombcrypto-client-v2/unity-web-template/src/controllers/WalletUtils.ts` inside the `estimateGas` function.
*   **Calculation Method:**
    *   It uses Ethers.js `provider.getFeeData()` to fetch the dynamic `gasPrice`.
    *   It also uses `provider.estimateGas()` to get the `gasLimit`.
*   **Vulnerability:**
    *   While it fetches dynamic `gasPrice`, Polygon is highly susceptible to sudden congestion spikes. Ethers.js standard `getFeeData()` often returns values that immediately become stale.
    *   If the transaction is sent with the exact `gasPrice` returned at that exact millisecond, and block base fees jump, the transaction will get stuck or fail (Revert/Drop).
    *   There is no "buffer" or "premium" multiplier applied to `maxFeePerGas` / `maxPriorityFeePerGas` (EIP-1559 standard) for Polygon.

#### B. Market (React / Ethers.js)
*   Similar to the client, transaction building typically relies on the default provider behavior. If it doesn't apply an EIP-1559 buffer for Polygon, transactions will drop during spikes.

---

## THE BROKEN LINKS (Vulnerabilities Identified)

1.  **NO RPC FALLBACK FOR POLYGON (Client & Market UI):**
    *   The WebGL Client and React Market are using single, hardcoded Polygon RPC URLs (`https://polygon-rpc.com/` and `https://polygon-mainnet.infura.io/`).
    *   If this single endpoint rate-limits, blocks the IP, or drops the connection, the user instantly fails to login or send transactions. BSC survives because its array contains 5 endpoints.

2.  **VULNERABLE GAS PRICING ON POLYGON (Client):**
    *   `WalletUtils.ts` relies strictly on `provider.getFeeData().gasPrice`. It does not explicitly construct EIP-1559 transactions (`maxFeePerGas`, `maxPriorityFeePerGas`) with an aggressive buffer.
    *   Polygon network congestion frequently requires a 10-20% higher max fee to ensure inclusion in the next block. Without this, the transaction gets dropped from the mempool.

---

## RECOMMENDED FIX STRATEGY (The Cure)

1.  **Implement Robust RPC Fallbacks (Client & Market UI):**
    *   Update `getAllRpc` in `bombcrypto-client-v2` to include an array of reliable public/private Polygon RPCs (e.g., Alchemy, QuickNode, Ankr, official Polygon RPCs).
    *   Update the Market frontend configuration to support an array of RPCs and implement a provider wrapper that catches timeout/connection errors and cycles to the next RPC.

2.  **Upgrade to EIP-1559 Aggressive Gas Pricing (Client):**
    *   In `WalletUtils.ts` (`estimateGas` and `sendTransaction`), transition away from legacy `gasPrice`.
    *   Fetch `maxFeePerGas` and `maxPriorityFeePerGas`.
    *   Specifically for the `Polygon` chain ID (137), apply a multiplier (e.g., `1.2x` to `1.3x`) to the `maxPriorityFeePerGas` to ensure the transaction outbids congestion and doesn't fail.

3.  **Server `ap-login` Audit (Note):**
    *   Since the actual Polygon signature verification happens in the `ap-login` service (not present in this repo), the infrastructure team must ensure the `ap-login` environment variables also point to an array of RPCs or a load-balanced RPC proxy, rather than a single endpoint.
