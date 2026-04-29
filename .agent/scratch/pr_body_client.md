# [PvP Revival v2] Wager UI & Network-Aware Client (Unity)

This PR introduces the frontend changes for the **PvP Revival v2** update, focusing on the new wagering interface and chain-specific token support.

## 🛠️ Key Changes
- **Wager Selection UI**: New screen for choosing match tiers and token types (BCOIN/SEN).
- **Dynamic Token Detection**: Automatic network-to-token mapping (BSC -> BCOIN, Polygon -> SEN).
- **Security**: Implemented signed request handlers for secure wagering and movement.
- **Battle Royale HUD**: Updated interface to support multi-player HUDs for 10-player rooms.

## 🔗 Project Context
This update completes the user-facing part of the PvP revival. Linked PRs:
- Server Logic: [PR #12 (Server)](https://github.com/alanvito1/bombcrypto-server-v2/pull/12)
- API Infrastructure: [PR #1 (API)](https://github.com/alanvito1/bombcrypto-api-v2/pull/1)

## 🎯 Objective
Empower players with a sustainable and competitive PvP environment as a suggestion for Senspark's ecosystem expansion.
