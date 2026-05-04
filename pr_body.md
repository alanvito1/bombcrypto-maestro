## Description

This PR introduces improved error reporting for marketplace listings to address a widespread community bug where users are unable to list their characters (Heroes) and houses on the BSC and Polygon networks.

### The Problem
Currently, when a user attempts to list an NFT and the smart contract reverts the transaction, the frontend catches the error but only returns a generic `"fail"` string. The user is then shown a vague "Your assets listing failed" message. This prevents both the community and the development team from diagnosing the true root cause of the failures.

Potential on-chain revert reasons for `createOrder` include:
- `Token address not in whitelist` (if BCOIN/SEN addresses aren't configured on the new network).
- `not pass sellable rule` (if rarity rules or cooldown block numbers are incorrectly configured).
- `blacklist` or `Not NFT owner`.

### The Solution
We updated `smc.tsx` to properly capture the revert reason from the ethers.js `error` object. The `updateStatus` functions in both `inventory-bhero.tsx` and `inventory-bhouse.tsx` now pass this detailed reason down to the `SellFail` modal, allowing users to see exactly why their transaction was rejected by the smart contract.

This is the first critical step to solving the listing bug, as it will reveal whether the issue stems from missing contract admin configurations (whitelist/sellable rules) or user-specific edge cases.
