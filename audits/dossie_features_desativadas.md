# 🔍 DOSSIÊ COMPLETO: Features Desativadas, Paradas e Abandonadas
## Ecossistema BombCrypto Senspark — Investigação Profunda

> [!IMPORTANT]
> Este dossiê cataloga **todas as features encontradas** que estão desativadas, incompletas, comentadas, marcadas como "Coming Soon", ou abandonadas dentro dos 5 subrepositórios do ecossistema BombCrypto Maestro.

---

## 📋 ÍNDICE DE ACHADOS

| # | Feature | Status | Subrepo | Risco de Reativação |
|---|---------|--------|---------|---------------------|
| 1 | **BHouse Items (Coming Soon)** | 🟡 Placeholder | market-v2 | Baixo |
| 2 | **BHouse Market Filters** | 🟡 Comentado | market-v2 | Baixo |
| 3 | **Shield Data API** | 🔴 Desativado | market-v2 | Médio |
| 4 | **WalletConnect + Coinbase** | 🔴 Desativado | market-v2 | Médio |
| 5 | **Bridge Withdraw (user)** | 🔴 Comentado | contract-v2 | Alto |
| 6 | **Rock Pack Shop (BHeroS)** | 🔴 Comentado | contract-v2 | Médio |
| 7 | **Shield Level Upgrade (old)** | 🟡 Substituído | contract-v2 | N/A |
| 8 | **ERC-404 Hybrid Token** | 🟤 Experimental | contract-v2 | Alto |
| 9 | **Champion SBT** | 🟤 Pronto s/ uso | contract-v2 | Baixo |
| 10 | **SEN Polygon Presale** | 🟡 Pausável | contract-v2 | Baixo |
| 11 | **BCoin Staking 2024** | ✅ Ativo (verificar) | contract-v2 | Baixo |
| 12 | **BHero Staking V2** | ✅ Ativo (verificar) | contract-v2 | Baixo |
| 13 | **SEN Staking** | ✅ Ativo (verificar) | contract-v2 | Baixo |
| 14 | **Cross-Chain Bridge** | 🟡 Pausável | contract-v2 | Médio |
| 15 | **MasterRewardPool** | 🟤 Pronto s/ uso | contract-v2 | Baixo |
| 16 | **Ronin Chain (RON)** | 🟤 Scaffolding | contract-v2 | Alto |
| 17 | **PVP Matching API** | 🟤 Em dev | server-v2 | Alto |
| 18 | **Treasure Hunt Mode** | 🟤 Em dev | api-v2 | Alto |
| 19 | **Unity Telegram Template** | 🟤 Scaffolding | client-v2 | Médio |
| 20 | **Unity Solana Template** | 🟤 Scaffolding | client-v2 | Alto |
| 21 | **Unity Airdrop Template** | 🟤 Scaffolding | client-v2 | Médio |
| 22 | **Case Normalizer Migration** | 🟡 TODO | market-v2 | Baixo |
| 23 | **BHeroS Fusion System** | ✅ Ativo | contract-v2 | N/A |
| 24 | **Batch Transfer** | 🟤 Utilitário | contract-v2 | Baixo |

---

## 🏠 ACHADO PRINCIPAL: BHouse Items — "Coming Soon"

### Localização
- [wallet.tsx](file:///c:/bomb/bombcrypto-market-v2/frontend/src/views/account/wallet.tsx#L69-L82)

### O que é
Na página **Wallet** do marketplace, existem 5 slots de informação:
1. ✅ **SEN Token** — Saldo SEN (BSC ou Polygon)
2. ✅ **BCOIN Token** — Saldo BCOIN (BSC ou Polygon)
3. ✅ **BHero** — Quantidade de heróis NFT
4. ✅ **BHouse** — Quantidade de casas NFT
5. 🟡 **iTEM (Coming Soon)** — Ícone de "cama" (`bed.webp`)

### Análise
O 5º slot mostra um ícone de **cama/bed** com texto `-- iTEM` e `Coming Soon`. Isso indica que a Senspark planejou um sistema de **itens para as Houses** — provavelmente equipamentos/mobília para as casas (camas, decorações, power-ups) que dariam bônus aos heróis dentro das BHouses.

### Evidências de código
```tsx
// wallet.tsx L76-82
<Item>
  <div className="image">
    <img src="/icons/bed.webp" alt="" />
  </div>
  <div>-- iTEM</div>
  <p>Coming Soon</p>
</Item>
```

### Estado da infraestrutura
- **Smart Contract**: ❌ Não existe contrato para "Items"
- **Database**: ❌ Não há tabela `item_orders` no schema
- **API**: ❌ Sem endpoints de items
- **Frontend**: 🟡 Apenas placeholder visual

### Conclusão
> Feature planejada mas **nunca iniciada** além do placeholder visual. Seria um sistema de NFT complementar às Houses, provavelmente itens de mobília com stats de bônus. **Grau máximo de abandono — nunca saiu do mockup.**

---

## 🏘️ Sistema BHouse — Análise Completa

### O que já está ATIVO

O sistema BHouse é **completo e funcional** nas duas redes:

| Componente | BSC | Polygon |
|-----------|-----|---------|
| NFT Token (BHouseToken.sol) | ✅ `0xea35...` | ✅ `0x2d5f...` |
| Market Contract (BHouseMarket.sol) | ✅ `0x0498...` | ✅ `0xBb59...` |
| Frontend Market Page | ✅ market-bhouse.tsx | ✅ |
| Detail Page | ✅ bhouse-id.tsx | ✅ |
| Inventory Page | ✅ house.tsx | ✅ |
| DB Tables | ✅ bsc.house_orders | ✅ polygon.house_orders |

### Tipos de BHouse (Raridades)
| Rarity | Nome | Min Price (BCOIN) |
|--------|------|------------------|
| 0 | Tiny House | 18 |
| 1 | Mini House | 60 |
| 2 | Luxury House | 135 |
| 3 | PentHouse | 240 |
| 4 | Villa | 375 |
| 5 | Super Villa | 540 |

### Atributos das Houses
- **id** — Identificador único
- **index** — Índice interno
- **rarity** — 0-5 (tipos acima)
- **recovery** — Taxa de recuperação de stamina dos heróis
- **capacity** — Quantos heróis cabem na casa
- **blockNumber** — Bloco de criação (cooldown de venda)

### Filtros de BHouse COMENTADOS no frontend
```tsx
// market-bhouse.tsx L223-238 — Stats e Abilities commentados
{/*<div className="title">Stats</div>*/}
{/*<Slider min={1} max={5} name="level" onChange={onChange} />*/}
{/*<Field label="Power" name="bomb_power" />*/}
{/*<Field label="Speed" name="speed" />*/}
{/*<Field label="Stamina" name="stamina" />*/}
{/*<Field label="Bomb num" name="bomb_count" />*/}
{/*<Field label="Range" name="range" />*/}
{/*<div className="title">Ability</div>*/}
{/*<Ability onChange={onChange} name="ability" />*/}
```

> Esses filtros seriam para filtrar Houses por stats avançados, mas foram cortados pois Houses não têm esses atributos (são dos heróis). Parece código copiado do BHero market sem cleanup.

---

## 🛡️ Shield Data API — Desativado

### Localização
- [market.tsx](file:///c:/bomb/bombcrypto-market-v2/frontend/src/views/market.tsx#L212-L231)

### O que é
Sistema para buscar dados de Shield dos heróis S no marketplace. A API `https://api-test.bombcrypto.io/shield` está **completamente comentada**.

```tsx
// market.tsx L217-231
// const fetchShieldData = async (data) => {
//   const resp = await axios.post("https://api-test.bombcrypto.io/shield", {
//     ids: data,
//   });
//   if (resp.data?.message) {
//     setDataShield(resp.data?.message);
//   }
// };
```

### FIXME do dev
```tsx
// FIXME: nhanc18 check sau — developer "nhanc18" marcou para "verificar depois"
```

### Estado
API de teste (`api-test`), nunca migrada para produção. Bloqueada por CORS ou desativada no backend.

---

## 🔗 WalletConnect + Coinbase — Desativado

### Localização
- [providerOptions.ts](file:///c:/bomb/bombcrypto-market-v2/frontend/src/providerOptions.ts)

### O que era
Integração com **WalletConnect v1** e **Coinbase Wallet** para login no marketplace.

### Por que foi desativado
```ts
// FIXME: nhanc18 disable walletconnect vì lỗi
// (Tradução do vietnamita: "desabilitar walletconnect por causa de erro")
```

O WalletConnect v1 SDK foi **deprecado oficialmente**. A Senspark nunca migrou para v2. Resultado: somente MetaMask funciona.

---

## 🌉 Bridge — Withdraw Comentado

### Localização
- [BBridge.sol](file:///c:/bomb/bombcrypto-contract-v2/base-hardhat/contracts/BBridge.sol#L132-L143)

### O que é
O contrato BBridge permite transferência cross-chain de tokens. A função `withdraw()` para usuários foi **comentada**:

```solidity
// function withdraw(uint256 amount) external onlyRole(WITHDRAWER_ROLE) {
//   require(amount > 0);
//   require(balances[msg.sender] >= amount);
//   IERC20(token).transfer(msg.sender, amount);
//   balances[msg.sender] -= amount;
// }
```

### Funcionalidades ativas
- ✅ `deposit()` — Depositar tokens na ponte (mín 200, máx 50.000)
- ✅ `bridgeFrom()` / `bridgeTo()` / `bridgeToV2()` — Transfer cross-chain via admin
- ✅ `adminWithdraw()` — Admin retira fundos
- 🟡 `isPause` / `isPauseBridge` — Flags de pause (controlado pelo PAUSER_ROLE)

### Objetivo
Ponte BSC ↔ Polygon para tokens BCOIN/SEN. O user deposita na chain A, admin (BRIDGER_ROLE) libera na chain B. Taxa de 10%.

---

## 💎 Rock Pack Shop — Comentado no BHeroS

### Localização
- [BHeroS.sol](file:///c:/bomb/bombcrypto-contract-v2/base-hardhat/contracts/BHeroS.sol#L564-L600)

### O que era
Uma **loja de Rock Packs** dentro do contrato BHeroS. Rocks são usados para reset de shield dos S-Heroes. A loja venderia packs de pedras por BCOIN ou SEN:

```solidity
// function buyRockPack(uint256 coinType, uint256 packId) external {
//   if (coinType == 0) { // BCOIN
//     bcoinToken.transferFrom(msg.sender, address(this), price);
//   } else if (coinType == 1) { // SEN
//     senToken.transferFrom(msg.sender, address(this), price);
//   }
//   userInfos[msg.sender].totalRock += numRockPacks[packId];
// }
```

### Estado
Variáveis declaradas mas **nunca preenchidas** (`bcoinRockPackPrices`, `senRockPackPrices`, `numRockPacks`). 100% comentado.

---

## 🧪 ERC-404 Hybrid Token — Experimental

### Localização
- [ERC404.sol](file:///c:/bomb/bombcrypto-contract-v2/base-hardhat/contracts/ERC404.sol)
- [My404.sol](file:///c:/bomb/bombcrypto-contract-v2/base-hardhat/contracts/My404.sol)

### O que é
O padrão **ERC-404** é um híbrido ERC-20/ERC-721 com liquidez nativa e fracionamento. Permite que um token funcione como ERC-20 (fungível) e automaticamente mint/burn NFTs quando transferido.

### Implementação
- `My404` herda `ERC404` com supply de 10.000 tokens
- Nome: "My404", Símbolo: "MY404"
- 18 decimais, owner recebe todo o supply

### Estado
**Experimental puro**. Sem deploy script dedicado, sem integração com o ecossistema BombCrypto. Parece ser um estudo/PoC da Senspark sobre o padrão ERC-404 para possível uso futuro.

---

## 🏆 Champion SBT — Pronto mas sem uso

### Localização
- [ChampionSBT.sol](file:///c:/bomb/bombcrypto-contract-v2/base-hardhat/contracts/ChampionSBT.sol)
- [deploy-champion-sbt.js](file:///c:/bomb/bombcrypto-contract-v2/base-hardhat/scripts/deploy-champion-sbt.js)

### O que é
Um **Soulbound Token (SBT)** chamado "Bomb Crypto Champion" (BCC). SBTs são NFTs **não-transferíveis** — uma vez mintados, ficam para sempre na carteira do holder.

### Funcionalidades
- `mintSBT(address, string)` — Admin minta um SBT com nome customizado
- `_beforeTokenTransfer` — Bloqueia transferência (`require(from == address(0))`)
- Nomes customizáveis por token (`tokenNames` mapping)

### Objetivo provável
Troféu para campeões de torneios PVP ou eventos especiais. Deploy script existe, mas não há evidência de deploy real.

---

## 💰 SEN Polygon Presale — Pausável

### Localização
- [SenPolygonPresale.sol](file:///c:/bomb/bombcrypto-contract-v2/base-hardhat/contracts/SenPolygonPresale.sol)

### O que é
Mecanismo de pré-venda do token SEN na Polygon. Usuários depositam USDT (mín $20, máx $200) e também precisam fazer um depósito de BCOIN (1.500) ou SEN (5.000) como colateral.

### Estado
- `isPause = false` no deploy — Inicialmente **ativo**
- `isUserWithdraw = false` — Saque do usuário **bloqueado por padrão**

### Situação
Provavelmente já **encerrada** (presale é evento único), mas o contrato ainda pode estar deployado on-chain.

---

## 📊 Staking Systems — Estado

### BCoinStake2024
- **Contrato**: BCoinStake2024.sol
- **Objetivo**: Staking de BCOIN com recompensas por 24 meses (tokenUnlock de 20.000/mês)
- **Taxa de saque**: Regressiva (15% no dia 1, 0% após 16+ dias)
- **Estado**: ✅ Deploy script existe. Provavelmente **ativo** on-chain.

### SEN Staking
- **Contrato**: SenStake.sol
- **Objetivo**: Staking de SEN com recompensas baseadas em token unlock mensal
- **Estado**: ✅ Deploy script existe. Provavelmente **ativo** on-chain.

### BHero Staking V2
- **Contrato**: BHeroStake.sol
- **Objetivo**: Stake de tokens (BCOIN, SEN, etc.) vinculados a heróis específicos
- **3 níveis projetados**:
  1. Stake coin → Shield (L → S Hero)
  2. Stake mínimo → Qualificação TH 1.1
  3. Rank mining para TH 2.0
- **V2**: Multi-token, weighted average de tempo de stake
- **Estado**: ✅ Deploy script existe. Provavelmente **ativo** on-chain.

---

## 🌐 Ronin Chain — Scaffolding

### Localização
- [ron-base/](file:///c:/bomb/bombcrypto-contract-v2/ron-base)
- [deploy-ronin.md](file:///c:/bomb/bombcrypto-contract-v2/ron-base/deploy-ronin.md)

### O que é
Preparação para deploy de contratos na **Ronin Chain** (rede do Axie Infinity):
- `NativeTokenDepositor.sol` — Único contrato, para depósito de tokens nativos
- `deploy-ronin.md` — Guia completo de deploy via Hardhat
- Configuração de redes (Ronin mainnet chainId 2020, Saigon testnet chainId 2021)

### Estado
**Scaffolding inicial** — apenas 1 contrato simples e documentação. A expansão para Ronin parece ter sido **abandonada antes de começar**.

---

## ⚔️ PVP Matching API — Em desenvolvimento

### Localização
- [pvp-matching/](file:///c:/bomb/bombcrypto-server-v2/api/pvp-matching)

### O que é
API de matchmaking para o modo **PVP** (Player vs Player) do BombCrypto. Projeto TypeScript com:
- Docker compose (deploy containerizado)
- Directory `data/` e `src/` (lógica de matching)
- Vitest para testes

### Estado
Estrutura criada com `README.md` básico (114 bytes). **Em estágio embrionário**.

---

## 🗺️ Treasure Hunt Mode — Em desenvolvimento

### Localização
- [th-mode-client/](file:///c:/bomb/bombcrypto-api-v2/th-mode-client) — Frontend Vite + TS
- [th-mode-server/](file:///c:/bomb/bombcrypto-api-v2/th-mode-server) — Backend TS + Vitest

### O que é
O modo **Treasure Hunt (TH)** — referenciado nos comentários do BHeroStake como "TH 1.1" e "TH 2.0". É o modo de jogo principal onde os heróis minam BCOIN. O subrepo `api-v2` contém client e server separados para este modo.

### Estado
Projetos com dependências instaladas e configuração Docker, mas **sem evidência de produção**.

---

## 📱 Unity Templates — Scaffolding

### Localização
- [unity-telegram-template/](file:///c:/bomb/bombcrypto-client-v2/unity-telegram-template)
- [unity-solana-template/](file:///c:/bomb/bombcrypto-client-v2/unity-solana-template)
- [unity-airdrop-template/](file:///c:/bomb/bombcrypto-client-v2/unity-airdrop-template)
- [unity-web-template/](file:///c:/bomb/bombcrypto-client-v2/unity-web-template)

### unity-telegram-template
- Template Vite + React para mini-app no Telegram
- Integração com TON Connect/Wallet
- **Estado**: Scaffold com package.json e env.sample. Nunca deploy.

### unity-solana-template
- Template para integração com Solana blockchain
- **Estado**: Scaffold básico. Expansão Solana **abandonada**.

### unity-airdrop-template
- Template para mecânica de Airdrop de tokens
- **Estado**: Scaffold básico. Feature de airdrop **não implementada**.

### unity-web-template
- Template para versão web do jogo (WebGL)
- **Estado**: Provavelmente o mais avançado, usado para builds WebGL.

---

## 🔧 TODOs e FIXMEs Encontrados

| Arquivo | Linha | Marcação | Descrição |
|---------|-------|----------|-----------|
| BHouseMarket.sol | 45 | `TODO` | Verificar interface 721 no initialize |
| BheroMarket.sol | 45 | `TODO` | Mesmo TODO (código duplicado) |
| market.tsx | 212 | `FIXME: nhanc18` | Check depois — Shield data |
| providerOptions.ts | 8, 35 | `FIXME: nhanc18` | WalletConnect desabilitado por erros |
| caseNormalizer.ts | 3 | `TODO` | Remover após migração completa |
| index.tsx (market) | 10 | `TODO` | Remover após migração completa |
| useGetTokenPayList.ts | 24 | `TODO` | Implementation pendente |

---

## 🏗️ MasterRewardPool — Pool de Recompensas Centralizado

### Localização
- [MasterRewardPool.sol](file:///c:/bomb/bombcrypto-contract-v2/base-hardhat/contracts/MasterRewardPool.sol)

### O que é
Um pool centralizado que transfere tokens para "child pools" usando limites configuráveis. Objetivo é ser o cofre mestre que distribui recompensas para os diferentes sistemas de staking.

### Estado
Contrato **pronto** mas sem evidência de deploy ou integração com o ecossistema.

---

## 📊 RESUMO POR REDE

### BSC (BNB Smart Chain)
| Feature | Endereço | Status |
|---------|----------|--------|
| BCOIN Token | `0x00e1...396D` | ✅ Ativo |
| SEN Token | `0xb43A...61b0` | ✅ Ativo |
| BHero NFT | `0x30cc...d618` | ✅ Ativo |
| BHouse NFT | `0xea35...96a` | ✅ Ativo |
| BHero Market | `0x376A...d704` | ✅ Ativo |
| BHouse Market | `0x0498...d108` | ✅ Ativo |
| Bridge | - | 🟡 Verificar on-chain |
| Staking | - | 🟡 Verificar on-chain |
| Items System | - | ❌ Não existe |

### Polygon
| Feature | Endereço | Status |
|---------|----------|--------|
| BCOIN Token | `0xB2C6...a1dC` | ✅ Ativo |
| SEN Token | `0xFe30...C22` | ✅ Ativo |
| BHero NFT | `0xd8a0...0854` | ✅ Ativo |
| BHouse NFT | `0x2d5f...6618` | ✅ Ativo |
| BHero Market | `0xf3a7...9812` | ✅ Ativo |
| BHouse Market | `0xBb59...A3be` | ✅ Ativo |
| Bridge | - | 🟡 Verificar on-chain |
| Presale | - | 🟡 Provavelmente encerrada |
| Items System | - | ❌ Não existe |

### Ronin
| Feature | Status |
|---------|--------|
| NativeTokenDepositor | 🟤 Scaffold apenas |

### Solana
| Feature | Status |
|---------|--------|
| Template Unity | 🟤 Scaffold apenas |

### Telegram/TON
| Feature | Status |
|---------|--------|
| Mini-app Template | 🟤 Scaffold apenas |

---

## 🎯 CONCLUSÕES E RECOMENDAÇÕES

### Features que ficaram pelo caminho (por prioridade de interesse)

1. **🏠 BHouse Items** — A feature mais óbvia "Coming Soon". Era para ser um sistema de equipamentos/mobília para casas, mas **nunca passou do placeholder**. Reativá-la exigiria criar um contrato ERC-721 de Items, integrar com as Houses, e criar toda a UI.

2. **🎮 PVP Mode** — O matchmaking está em estágio embrionário. O contrato ChampionSBT foi feito para premiar vencedores de PVP, mas o modo de jogo **nunca foi finalizado**.

3. **🌐 Multi-chain (Ronin/Solana/Telegram)** — A Senspark explorou expansão para Ronin, Solana e Telegram Mini-Apps, mas **abandonou todas** no estágio de scaffold.

4. **💎 Rock Pack Shop** — A loja de pedras para reset de shield dos S-Heroes está **100% comentada** no contrato, mas a infraestrutura está toda lá. Poderia ser reativada com relativamente pouco esforço.

5. **🧪 ERC-404** — Experimento futurista de token híbrido. Não tem relação direta com o ecossistema, mas mostra que a Senspark estudava inovações DeFi.

6. **🔗 WalletConnect** — A desativação do WalletConnect limita o marketplace a apenas MetaMask. Migrar para WalletConnect v2 poderia expandir o acesso.

### Estado geral
O ecossistema BombCrypto tem as **mecânicas core funcionando** (Heroes, Houses, Market, Staking), mas a Senspark **deixou pelo caminho** diversas features de expansão — Items para Houses, PVP, multi-chain, e monetização via Rock Packs. O padrão sugere um **pivot de prioridades** durante o desenvolvimento, com foco em manter o core estável ao invés de expandir features.
