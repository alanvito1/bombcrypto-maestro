# Plano de Implementação - PVP Wager & Battle Royale v1
**Data:** 2026-04-28
**Versão:** 1.0.0
**Branch Principal (Maestro):** `feature/pvp-wager-battle-royale-v1`

## Repositórios Afetados e Branches
| Repositório | Branch | Status |
|-------------|--------|--------|
| Maestro | `feature/pvp-wager-battle-royale-v1` | Ativo |
| bombcrypto-server-v2 | `feature/pvp-wager-v1` | Implementado |
| bombcrypto-api-v2 | `feature/pvp-matching-v1` | Implementado |
| bombcrypto-client-v2 | `feature/pvp-ui-v1` | Implementado |

## Resumo das Alterações (Phase 1 Concluída)

### 1. Server (Kotlin)
- **MatchRuleInfo**: Adicionado suporte para `gameMode` e `wagerMode`.
- **DynamicMapConfig**: Configuração de tempo de jogo (120s/150s/180s) e mapeamento de prefabs de mapa (`SMALL_1V1`, `MEDIUM_TEAM`, `LARGE_BR`).
- **PvpWagerManager**: Lógica de dedução de tokens (BlockReward) e cálculo de prêmios (70/20/10 para BR).
- **Matchmaking**: Isolação de filas por compound key em Redis.

### 2. API (TypeScript)
- **PvpData.ts**: Atualização das interfaces `IMatchRule` e `IMatchRuleInfo` para incluir os novos campos de modo e aposta.
- **MatchCreator.ts**: Refatoração da criação de regras para propagar os dados do usuário para o servidor.

### 3. Client (C# / Unity)
- **GuiMainMenu**: Fluxo integrado com Diálogos Premium (BL).
- **BLDialogPvpDisclaimer**: Modal de aviso de risco com opção "Não mostrar novamente".
- **BLDialogPvpWager**: Seleção de token (BSC/Polygon) e Tiers (1 a 100k).
- **Enums**: Registro de `PvpWagerTier` e `PvpWagerToken` em `PvpWagerConstant.cs`.

## Próximos Passos (Phase 2 em diante)
1. **PvpReadyScene**: Expandir o HUD para suportar 6 jogadores simultâneos no Battle Royale.
2. **Chat/Lobby**: Implementar sistema de mensagens na sala de espera.
3. **Mapas**: Validar e ajustar os prefabs de mapa Grande (31x21) no Unity.
4. **Resultados**: Atualizar diálogos de vitória/derrota para mostrar rankings de 1 a 6.

---
*Assinado: Antigravity AI*
