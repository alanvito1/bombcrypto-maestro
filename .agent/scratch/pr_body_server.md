# [PvP Revival v2] Sustainable Wager Engine (Server)

This PR implements the core backend logic for the **PvP Revival v2** initiative. It introduces a player-funded wagering system that ensures economic sustainability without depleting the project's reward pools.

## 🛠️ Key Changes
- **PvpWagerService**: Atomic escrow system using PostgreSQL `FOR UPDATE` locks to prevent double-spending.
- **PvpMatchManager**: Multi-player Battle Royale orchestrator supporting up to 10 participants.
- **PvpMatchShield**: Security layer that enforces "Disconnect = Forfeit" to prevent match manipulation.
- **Scalability**: Implemented a shared executor pool to handle 10k+ concurrent rooms efficiently.
- **Ledger**: New `pvp_fee_ledger` for platform fee tracking (5% treasury fee).
- **Network Isolation**: Strict token-network validation (BSC vs Polygon).

## 🔗 Project Context
This is a massive update that depends on corresponding changes in:
- `bombcrypto-api-v2` (Matching & Leaderboards)
- `bombcrypto-client-v2` (Wager UI)

## 🎯 Objective
Revive the PvP system as a suggestion to Senspark, promoting entertainment and community engagement while ensuring the rewards ecosystem remains healthy.
