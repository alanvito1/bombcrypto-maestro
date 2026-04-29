# Implementation Plan - PvP Wager & Battle Royale (v1.0.0)
**Date:** 2026-04-28
**Author:** Antigravity (AI Assistant)
**Status:** In Progress (Phase 0 Audit Complete, Phase 1 UI Started)

## 1. Versioning & Branches
To ensure isolated and coupled development within Senspark standards, the following branches will be used across repositories:

- **Maestro:** `feature/pvp-wager-battle-royale-v1`
- **Client (Assets):** `feature/pvp-wager-battle-royale-v1`
- **Server (SFS):** `feature/pvp-wager-battle-royale-v1`

## 2. Completed Tasks (Phase 0 - Core Logic)
### Server-Side (BombChainExtension)
- [x] **Wager Constants:** Aligned `PvpWagerToken` and `PvpWagerTier` with client-side IDs.
- [x] **Prize Distribution:** Implemented 70/20/10 split for Battle Royale and 100% for 1v1 after a 5% fee.
- [x] **Multi-Network Support:** Updated `PvpResultManager` to handle rewards on BSC and Polygon networks based on the wager token.
- [x] **Matchmaking:** Verified `FFA_6` mode support for Battle Royale.

### Client-Side (Unity)
- [x] **Wager Selection Logic:** Updated `FindMatchController` to support wager parameters (Tier, Token) and Battle Royale mode.
- [x] **Lobby UI Support:** Modified `PvpReadyScene.cs` and `BLGuiPvp.cs` to support up to 6 players dynamically.
- [x] **Result Display:** Updated `BLDialogPvpWin/Lose.cs` to show Rank (1-6) instead of 1v1 scores for Battle Royale.

## 3. Pending Tasks (Phase 1 - UI/UX & Polish)
### Client-Side (Unity)
- [ ] **Wager Selection Dialog:** Finalize the UI for selecting Wager Tier/Token in the Main Menu.
- [ ] **Disclaimer Modal:** Implement the mandatory risk disclaimer before joining a wager match.
- [ ] **Lobby Chat:** Add communication/emoji system in the `PvpReadyScene` waiting room.
- [ ] **Prefab Expansion:** Expand `PvpReadyScene.prefab` slots for players 3-6.

## 4. Verification Plan
- [ ] **Local Integration Test:** Run client and server locally to verify wager deduction and reward credit.
- [ ] **BR Flow:** Verify 6-player start and death ranking order.
- [ ] **Multi-Network Test:** Verify BCOIN/SEN rewards on both BSC and Polygon.

## 5. Deployment Standards
- All code must pass `checklist.py` before merging.
- Branch naming follows `feature/` prefix.
- Multi-repository changes must be synchronized in Maestro.
