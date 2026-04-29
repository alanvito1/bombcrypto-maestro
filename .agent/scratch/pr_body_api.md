# [PvP Revival v2] Matchmaker & Ranking API (Node.js)

This PR implements the API and Matchmaking updates for the **PvP Revival v2** project. It enables cross-submodule communication for the new Battle Royale mode and chain-isolated rankings.

## 🛠️ Key Changes
- **Network-Aware Matchmaking**: Updated Redis Matchmaker to propagate the `network` context (BSC/Polygon), ensuring players only match on their native chain.
- **Leaderboard V2**: Enhanced rankings to filter by token and network.
- **Validation Middleware**: Added checks to prevent cross-chain wagering attempts.
- **Infrastructure**: Updated Redis schemas to support multi-player Battle Royale slots.

## 🔗 Project Context
This update is part of a larger initiative to revive PvP. Linked PRs:
- Server Logic: [PR #12 (Server)](https://github.com/alanvito1/bombcrypto-server-v2/pull/12)
- Client UI: (Pending)

## 🎯 Objective
Provide the necessary API infrastructure to support a player-funded PvP ecosystem that is secure, scalable, and sustainable.
