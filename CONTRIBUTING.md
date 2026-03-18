# 📜 Developer Manifesto & Sub-Repository Isolation Rules

Welcome, Developer. This document contains the guiding principles and rules for contributing to the **Bomb Crypto V2 Megazord**.

## 🛡️ The Golden Rule: Sub-Repository Isolation

1. **The Hub (Root) is the Brain**: All orchestration scripts (`start-megazord.sh`, `doctor-megazord.sh`, `clean-megazord.sh`), global configurations (`docker-compose.yml`), and system architecture documentation MUST reside in the Root (`/bomb`).
2. **Submodules are Untouchable for Orchestration**: Never create ecosystem-wide boot scripts or modify `.gitmodules` from within `bombcrypto-client-v2`, `bombcrypto-server-v2`, or `bombcrypto-market-v2`. These repositories must remain agnostic of each other.
3. **Zero Touch Submodule Updates**: If you need to make changes to a submodule, checkout its branch locally, make the physical changes inside the submodule, commit them within the submodule, and then update the Git pointer from the Root directory (`/bomb`). Never rely on complex remote `submodule update` commands that merge out-of-sync history.

## 🤝 Code Contribution Standards

1. **No "Black Boxes"**: If a script is added, it must be documented in `README.md` and have an explicit "Why" in its preamble.
2. **Visualize the Architecture**: Whenever altering the sequence of API calls or database states, use **Mermaid.js** diagrams to update the `SYSTEM_ATLAS.md` or `README.md`.
3. **Prefer Native Solutions**: Avoid exotic libraries (e.g., Object Pooling in Unity, DB pagination in PostgreSQL). Simple, established patterns are prioritized over premature low-level optimizations (like Assembly in Solidity).

## 🧰 Environment Alignment (`.env` & Magic Numbers)

- Always consult `SYSTEM_ATLAS.md` before changing ports, API URLs, or authentication keys (like `AP_LOGIN_TOKEN` or `JWT_BEARER_SECRET`).
- **DO NOT** commit real `.env` files into source control. Always work with `.env.example`.
- Run `./doctor-megazord.sh` before you boot to catch conflicting ports.

## 🐛 Bug Reports & Ambiguities

If you encounter technical debt or ambiguities within the codebase (e.g., from original Senspark logic), do not attempt to patch it globally. Log the anomaly in `.scribe/journal.md`. Document the risk, how it affects the current local setup, and suggest an isolated fix.