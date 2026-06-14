# New Rarities and Mint Probabilities

This document summarizes the new rarities (6-9) and their minting probabilities found in the sub-repositories.

## Branches
- **Main Repo**: `feat/advanced-rarities` (created for orchestration)
- **Sub-repositories** (`bombcrypto-contract-v2`, `bombcrypto-server-v2`): `feature/advanced-rarities-activation`

## Rarity List
| ID | Name |
|----|------|
| 0 | Common |
| 1 | Rare |
| 2 | Super Rare |
| 3 | Epic |
| 4 | Legend |
| 5 | Super Legend |
| 6 | Mega |
| 7 | Super Mega |
| 8 | Mystic |
| 9 | Super Mystic |

## Mint Probabilities (Drop Rates)
Total weight: 10,000

| Rarity | Name | Weight | Probability |
|--------|------|--------|-------------|
| 0 | Common | 8118 | 81.18% |
| 1 | Rare | 962 | 9.62% |
| 2 | Super Rare | 481 | 4.81% |
| 3 | Epic | 240 | 2.40% |
| 4 | Legend | 112 | 1.12% |
| 5 | Super Legend | 51 | 0.51% |
| 6 | Mega | 22 | 0.22% |
| 7 | Super Mega | 9 | 0.09% |
| 8 | Mystic | 4 | 0.04% |
| 9 | Super Mystic | 1 | 0.01% |

## Stats Ranges (New Rarities)
| Rarity | Name | Stamina | Speed | Bomb Count | Bomb Power | Bomb Range | Ability Count |
|--------|------|---------|-------|------------|------------|------------|---------------|
| 6 | Mega | 18-21 | 18-21 | 7 | 18-21 | 7 | 7 |
| 7 | Super Mega | 21-24 | 21-24 | 8 | 21-24 | 8 | 7 |
| 8 | Mystic | 24-27 | 24-27 | 9 | 24-27 | 9 | 7 |
| 9 | Super Mystic| 27-30 | 27-30 | 10 | 27-30 | 10 | 7 |

## Source Files
- `bombcrypto-server-v2/server/BombChainExtension/src/com/senspark/game/data/model/ServerHeroDetails.kt`
- `bombcrypto-server-v2/server/db/migrations/20260403_expand_rarities_6_to_9.sql`
