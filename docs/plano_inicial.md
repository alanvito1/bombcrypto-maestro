# PVP Revival v2: Battle Royale, Apostas BCOIN/SEN & Ranking

## Progress Status
- [x] Phase 0: Infraestrutura Base
- [x] Phase 1: Modos de Jogo (Backend Engine)
- [/] Phase 2: Sistema de Apostas UI (In Progress)
- [/] Phase 3: Risk Disclaimer (In Progress)
- [ ] Phase 4-9: Pending

## Descobertas da Varredura

### Redes Confirmadas
- **BSC** e **POLYGON** operacionais (`EnumConstants.DataType.BSC`, `DataType.POLYGON`)
- Tokens: **BCOIN** (`TokenType.BCOIN`) e **SEN** (`SENSPARK`/`SENSPARK_DEPOSITED`)
- Ambos tokens existem nas duas redes com contratos diferentes
- Login tipo `BNB_POL(0)` = BSC + Polygon unificado
- `UserNameSuffix` diferencia contas por rede (`bsc`/`polygon` suffix)

### Padroes Senspark Encontrados
- **Terms/Disclaimer**: `IUserAccountManager.IsTermsServiceAccepted()` / `SetTermsServiceAccepted()` com `DialogTermsService` e `TermServiceConfirm.cs`
- **Warning Dialogs**: `DialogAmazonWarning`, `DialogWarningBeforeBuyHouse`, `AfDialogSyncAccWarning` - pattern de dialog com callback accept/reject
- **Bot System**: `GlobalMatchmaker.generateBotConfig()` com `isBot=true` flag - bots gerados com configs de heróis reais
- **Leaderboard existente**: `bombcrypto-api-v2/th-mode-server` (Express/TS) + `th-mode-client` (React/Vite/Ant Design) com filtro BSC/Polygon, auto-refresh, pool tables

### API Leaderboard Pattern (th-mode)
- Server: Express + Redis messenger + cached JSON response
- Client: React + Ant Design + Framer Motion + BrowserRouter
- Route: `GET /leaderboard` com rate limiting por IP
- Data model: `IHeroInfo` com `stakeBcoin`, `stakeSen`, `network: Network.BSC|POLYGON`
- Navigation: single route `/` com `MainNavigation.tsx`

---

## Plano Atualizado (10 Fases)

### FASE 0: Infraestrutura Base (Sem. 1-2)

#### Server (Kotlin)
- [NEW] `PvpGameMode.kt` - Enum: `DUEL_1V1`, `TEAM_2V2`, `TEAM_3V3`, `BATTLE_ROYALE_6P`
- [NEW] `PvpWagerMode.kt` - Enum: `FREE`, `WAGERED`
- [NEW] `PvpWagerToken.kt` - Enum com rede+token: `BCOIN_BSC`, `BCOIN_POLYGON`, `SEN_BSC`, `SEN_POLYGON`
- [MODIFY] `IMapConfig.kt` - Add `maxPlayers: Int`, `mapPatternId: String`
- [NEW] Map patterns: Small (15x11, 2 spawns), Medium (21x15, 4-6 spawns), Large (31x21, 6 spawns)
- [MODIFY] `PvpMapGenerator.kt` - Map pattern registry por `PvpGameMode`

#### Testes
- `PvpGameModeTest.kt`, `PvpMapGeneratorMultiSizeTest.kt`

---

### FASE 1: Modos de Jogo (Sem. 3-4)

#### Server
- [MODIFY] `MatchRuleInfo.kt` - Add `gameMode: PvpGameMode`, `wagerMode: PvpWagerMode`
- [MODIFY] `GlobalMatchmaker.kt` - Filas separadas por `gameMode+wagerMode`; **bots BLOQUEADOS** em `wagerMode=WAGERED`
- [MODIFY] `PvpMatchController.kt` - Battle Royale: eliminacao continua, ultimo vivo vence; Teams: ultimo time de pe
- [MODIFY] `PvpQueueManager.kt` - Aceitar `gameMode` + `wagerMode` no join

#### Regras de Modo
| Modo | Room Size | Team Size | Map | Durac |
|------|-----------|-----------|-----|-------|
| 1v1 | 2 | 1 | Small 15x11 | 120s |
| 2v2 | 4 | 2 | Medium 21x15 | 150s |
| 3v3 | 6 | 2 (3 cada) | Medium 21x15 | 150s |
| BR 6P | 6 | 1 (FFA) | Large 31x21 | 180s |

---

### FASE 2: Sistema de Apostas BCOIN/SEN (Sem. 5-7)

#### Tiers de Aposta Padronizados
`1, 5, 10, 25, 50, 100, 1000, 5000, 10000, 25000, 50000, 100000`

Aceita: BCOIN (BSC), BCOIN (Polygon), SEN (BSC), SEN (Polygon)
Todos jogadores da sala apostam **o mesmo valor e mesmo token**.

#### Server
- [NEW] `PvpWagerService.kt` - Escrow: debita ao entrar, lock atomico no DB
- [NEW] `PvpWagerConfig.kt` - Tiers, `feePercentage=5%`, `feeWallet` config
- [NEW] SQL Migration `pvp_wager_system.sql`:
  - `pvp_wager_pool` (match_id, token_type, network, total_pool, fee_amount, status)
  - `pvp_wager_entry` (match_id, user_id, amount, token_type, network, status)
  - `pvp_fee_ledger` (batch fees para treasury wallet)

#### Distribuicao de Premio
| Modo | 1o Lugar | 2o Lugar | 3o Lugar |
|------|----------|----------|----------|
| 1v1 | 100% pool (- fee) | - | - |
| 2v2 | Time vencedor divide | - | - |
| 3v3 | Time vencedor divide | - | - |
| BR 6P | 70% | 20% | 10% |

Fee 5% descontada ANTES da distribuicao. Fee segue para `pvp_fee_ledger` -> batch transfer para wallet Senspark usando `fn_update_user_bcoin_transaction` existente.

#### Seguranca do Escrow
- Lock atomico no PostgreSQL (SELECT FOR UPDATE)
- Refund automatico se partida nao iniciar em 60s
- Double-spend prevention via constraint UNIQUE(match_id, user_id)
- Bots **PROIBIDOS** em modo apostado

---

### FASE 3: Disclaimer & Blindagem de Partida (Sem. 7-8)

#### Client (Unity C#)
- [NEW] `DialogPvpWagerDisclaimer.cs` - Seguindo pattern `DialogWarningBeforeBuyHouse`
  - Checkbox "I understand I may lose my wagered tokens"
  - Checkbox "I accept the 5% platform fee on winnings"
  - Botao "Accept & Enter Match" (habilitado so com ambos checks)
  - Texto: "By entering a wagered PVP match, you acknowledge that disconnection or leaving mid-match will result in forfeiture of your wager."
- [NEW] `PvpWagerTermsManager.cs` - Seguindo pattern `IUserAccountManager.IsTermsServiceAccepted()`
- Blindagem: jogador que desconectar **perde a aposta** (server marca como FORFEIT)

---

### FASE 4: Lobby, Chat & Saguao (Sem. 9-11)

#### Arquitetura Recomendada (Industry Standard)
- **Lobby por modo**: Sala SFS2X publica por `PvpGameMode` (4 lobbies)
- **Chat global**: Canal SFS2X compartilhado entre todos os lobbies
- **Chat de sala**: Canal privado por match room
- Rate limit: 1 msg/s por jogador, filtro anti-spam

#### Server
- [NEW] `PvpLobbyExtension.kt` - Rooms publicas no SFS2X, broadcast de players online
- [NEW] `PvpChatManager.kt` - Chat via SFS2X Public Messages, rate limiting
- [NEW] `PvpLobbyStateManager.kt` - Exibe: jogadores online, partidas em andamento, top rankings
Fase 5: Integração End-to-End: Ciclo completo do jogador, do login à distribuição de prêmios e rankings.

---

## 📚 Documentação e Evidências por Repositório

Como parte do encerramento da sprint, a documentação técnica foi atualizada e centralizada em cada sub-repositório para garantir a rastreabilidade futura:

### 1. Game Server (Kotlin)
- **Local**: `bombcrypto-server-v2/server/BombChainExtension/docs/pvp-wagered-system.md`
- **Conteúdo**: Arquitetura de Escrow, Map Generation, Integrity Service e PvpFeeProcessor.
- **Evidência de Teste**: `src_test/` (Unit, Stress, Integrity).

### 2. API Leaderboard (Node.js)
- **Local**: `bombcrypto-api-v2/pvp-mode-server/docs/pvp-api-integration.md`
- **Conteúdo**: Rotas REST, validação de assinaturas e lógica de rankings.
- **Evidência de Teste**: `tests/Leaderboard.test.ts` (Vitest).

### 3. Web Client (React)
- **Local**: `bombcrypto-api-v2/th-mode-client/docs/pvp-ui-documentation.md`
- **Conteúdo**: Componentes Ant Design, Fetchers de rede e filtros de ranking.
- **Evidência de Teste**: `__tests__/PvpLeaderBoard.test.tsx`.

### 4. Unity Client (C#)
- **Local**: `bombcrypto-client-v2/Assets/Docs/pvp-client-documentation.md`
- **Conteúdo**: Ciclo de vida do player, Disclaimer system e UI reativa do lobby.
- **Evidência**: Auditoria de scripts reativos e handlers SFS2X.

---
> [!TIP]
> Todas as novas tabelas (`pvp_fee_ledger`, `pvp_wager_pool`) e o processador de taxas automático já estão operacionais e documentados para o time de infraestrutura.

#### Client (Unity)
- [NEW] `PvpLobbyScene` - Saguao com lista de players, selecao de modo/aposta
- [NEW] `PvpChatPanel.cs` - Chat lateral com tabs (Global / Sala)
- [NEW] `PvpModeSelector.cs` - Cards: 1v1, 2v2, 3v3, BR com toggle Free/Wagered

#### Matchmaking (Industry Best Practices)
- **ELO-based** para ranked (similar a League of Legends)
- **Ping-aware**: servidor seleciona room com menor latencia media
- **Queue timeout**: 30s free, 60s wagered, fallback para bot APENAS em free
- **Anti-smurf**: conta precisa de minimo X partidas free antes de apostar

---

### FASE 5: Rankings Semanal + Mensal (Sem. 12-13)

#### SQL Migration `pvp_rankings_v2.sql`
```sql
-- Ranking semanal
CREATE TABLE pvp_weekly_ranking (
    user_id INT, week_number INT, year INT,
    points INT DEFAULT 0, wins INT, losses INT,
    matches_played INT, game_mode VARCHAR(20),
    tier VARCHAR(20) DEFAULT 'BRONZE',
    UNIQUE(user_id, week_number, year, game_mode)
);
-- Ranking mensal
CREATE TABLE pvp_monthly_ranking (
    user_id INT, month INT, year INT,
    points INT DEFAULT 0, wins INT, losses INT,
    total_wagered DECIMAL(18,8), total_won DECIMAL(18,8),
    game_mode VARCHAR(20), tier VARCHAR(20),
    UNIQUE(user_id, month, year, game_mode)
);
```

#### Floor System (Tier-based)
| Tier | Min Points | Floor ao Reset |
|------|-----------|----------------|
| Bronze | 0 | 0 |
| Silver | 500 | 400 |
| Gold | 1200 | 1000 |
| Platinum | 2000 | 1700 |
| Diamond | 3000 | 2500 |
| Master | 5000 | 4000 |

Reset semanal: pontos caem para floor do tier. Reset mensal: pontos caem 1 tier.

---

### FASE 6: Leaderboard API & Web Client (Sem. 14-16)

#### Server API (Express/TS) - Seguindo pattern `th-mode-server`
- [NEW] `bombcrypto-api-v2/pvp-mode-server/` - Mesmo stack: Express + Redis + Vitest
- Routes:
  - `GET /pvp/leaderboard/weekly?mode=BR&network=BSC`
  - `GET /pvp/leaderboard/monthly?mode=ALL`
  - `GET /pvp/leaderboard/top-bettors`
  - `GET /pvp/leaderboard/top-winners`
  - `GET /pvp/leaderboard/top-losers`
  - `GET /pvp/leaderboard/top-players` (por win rate)

#### Web Client (React/Vite) - Seguindo pattern `th-mode-client`
- [MODIFY] `th-mode-client/src/components/navigations/MainNavigation.tsx` - Add rota `/pvp`
- [NEW] `th-mode-client/src/components/pvp-leaderboard/` - Tab-based:
  - Tab "Weekly Ranking" com tabela por modo
  - Tab "Monthly Ranking" com tier badges
  - Tab "Hall of Fame" - Top bettors, winners, losers
  - Filtro por rede (BSC/Polygon) seguindo `NETWORK_TO_STR_DROPDOWN` existente
  - Auto-refresh toggle seguindo `AutoRefreshToggle` existente

---

### FASE 7: Anti-Cheat & Seguranca (Sem. 17-18)

- [NEW] `PvpAntiCheatValidator.kt` - Rate limiting de acoes/tick, hash de estado
- [NEW] `PvpMatchIntegrityService.kt` - Log de replay, assinatura digital do resultado
- [NEW] `PvpMatchShield.kt` - Disconnect = forfeit, refund APENAS se match nao iniciou
- Validacao server-side de todos os movimentos (extend `MoveHeroHandler`)
- Deteccao de speed-hack via timestamp validation

---

### FASE 8: Testes Completos (Sem. 19-21)

#### Unit Tests (Kotlin/JUnit Jupiter - seguindo `src_test/` existente)
- `PvpMapGeneratorMultiSizeTest.kt`
- `PvpWagerServiceTest.kt` - escrow, distribute, refund
- `PvpMatchRulesMultiModeTest.kt`
- `PvpRankingWeeklyMonthlyTest.kt`
- `PvpBotBlockInWageredTest.kt`

#### Stress Tests
- 100 partidas simultaneas, 600 conexoes SFS
- 1000 jogadores na fila
- Transacoes BCOIN/SEN concorrentes

#### Security Tests
- Double-spend, movimentos invalidos, replay tampering
- Escrow race conditions

#### Visual Tests (Client)
- Screenshots de cada tela nova
- Responsividade em resolucoes diferentes

---

### FASE 9: Deploy & Monitoramento (Sem. 22-24)

1. **Staging** - Deploy completo
2. **Closed Beta** (50 players) - Apenas modo FREE
3. **Open Beta** - Free + Wagered com tiers baixos (1-100)
4. **Production** - Todos os tiers e modos

---

## Fee Collection Path

```
Player aposta BCOIN/SEN -> pvp_wager_entry (LOCKED)
    -> Match finaliza -> PvpWagerService.distribute()
        -> Vencedores: pool * (1 - feeRate)
        -> Fee: pool * feeRate -> pvp_fee_ledger
            -> Batch job -> fn_update_user_bcoin_transaction -> Senspark Treasury
```

Wallet treasury = mesma usada pelo marketplace (`user_activity_marketplace`).


🧪 Plano de Testes Organizado por Fases
Criei um guia estratégico que mapeia cada ferramenta de teste ao ciclo de vida do desenvolvimento. O plano está dividido em:

Fase 1: Lógica Core (Unit Tests): Foco em cálculos de aposta, geração de mapas e regras de vitória (JUnit 5).
Fase 2: Segurança (API/Integrity): Validação de assinaturas HMAC e integridade do contrato Server-API (Vitest/JUnit).
Fase 3: Stress e Concorrência: Simulação de alta carga (100 partidas simultâneas) para detectar race conditions no Escrow (Coroutines).
Fase 4: Experiência do Usuário (UI/Visual): Validação de componentes React/Ant Design e auditoria visual no Unity.
Fase 5: Integração End-to-End: Ciclo completo do jogador, do login à distribuição de prêmios e rankings.