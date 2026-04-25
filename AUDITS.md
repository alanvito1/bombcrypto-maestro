# Treasure Hunt & Security Audit Report

## 1. Treasure Hunt Mechanisms

### Online Mode (V2)
- **Architecture**: Distributed leaderboard system based on participation cycles.
- **Scoring**: Rewards are allocated based on a Score calculated as `Score = StakedAmount * TicketCount`.
- **Logic**: Each block explosion generates a "ticket". At the end of the cycle, players are ranked by Score and rewards are distributed from the global pool according to rarity tiers.

### Offline Mode (Auto-Mine)
- **Simulation**: Uses a statistical model based on `block_hp` and `block_value` from the database.
- **Hidden Decay**: A reward reduction table was identified in `AutoMineManager.kt`. Rewards drop as follows:
    - 0 to 60 minutes: **60%** efficiency.
    - 60 to 120 minutes: **40%** efficiency.
    - 120+ minutes: **10%** efficiency.
- **Online Exemption**: This reduction applies **only** to offline rewards (calculated upon login). Using the "Auto Play" button in the client keeps the user online and exempt from this decay.

## 2. Security & Centralization Audit

### Smart Contracts (`BHeroToken.sol`)
- **Role Centralization**: The `DEFAULT_ADMIN_ROLE` (deployer) has total control over `MINTER`, `DESIGNER`, `PAUSER`, and `CLAIMER` roles.
- **Privileged Minting**: The `createTokenRequest` function allows the `MINTER_ROLE` to specify a `rarity` (1-6) for guaranteed rare NFT generation, bypassing standard probability.
- **Asset Seizure**: The `fixTransfer` function allows a `DESIGNER_ROLE` holder to move any NFT from any wallet to another without owner approval or approval signatures.

### Server Integrity
- **Admin Commands**: `AdminCommandController.kt` provides moderators with high-privilege commands, including `kickUser` and `hotReload` for real-time config manipulation.
- **Authentication**: `UserLoginHandler.kt` uses standard JWT-like tokens and does not show obvious bypasses or backdoors for unauthorized access via "random wallets".

## 3. Conclusions
- **Game Economy**: The offline reward decay is a significant "invisible" mechanic that favors active online play over passive offline auto-mining.
- **Governance**: The ecosystem is highly centralized. Security depends entirely on the protection of the private keys holding administrative roles.
- **Exploit Resistance**: The contracts are robust against external attacks from unauthorized addresses due to strict `msg.sender` role checks.
