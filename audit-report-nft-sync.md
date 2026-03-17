# Relatório de Auditoria: O Limbo dos NFTs (State Desync) - "audit-report-nft-sync"
**Responsável**: Exterminador 🐞 (Lead Web3 Architect & Smart Contract Auditor)
**Data**: Março 2024
**Escopo**: Diagnóstico Cross-Repository do ecossistema Bomb Crypto V2 (Smart Contracts, Backend Indexer e Game Server)

## 1. Mapeamento de Contratos (On-Chain)

Os contratos do Marketplace (`BHeroMarket.sol` e `BHouseMarket.sol`) derivam do contrato abstrato `MarketCore.sol`. O fluxo de transações On-Chain emite eventos fundamentais que o sistema Off-Chain precisa escutar:

- **`createOrder`** (Listagem): Emite `CreateOrder(uint256 tokenId, uint256 price, uint256 tokenDetail, address seller)`
- **`buy`** (Venda): Emite `Sold(uint256 tokenId, uint256 price, uint256 tokenDetail, address seller, address buyer)`
- **`cancelOrder`** (Cancelamento): Emite `CancelOrder(uint256 tokenId)`

Durante o `createOrder`, a validação de propriedade (`_owns`) e o bloqueio (`approveForAll`) garantem que o NFT possa ser transacionado pela plataforma. Quando vendido (`_buy`), as taxas são processadas e o NFT é transferido via `safeTransferFrom`.

---

## 2. Auditoria do Indexador (Off-Chain)

O backend do Marketplace (`bombcrypto-market-v2/backend`) atua como o **Indexador Primário**.

### Mecanismo de Escuta e Robustez
A escuta de eventos ocorre nos serviços de Subscriber (`HeroSubscriber` e `HouseSubscriber`), que estendem `BaseSubscriber`. O mecanismo utiliza **HTTP Polling** através da API `blockchain-center-api`.
- O indexador controla um ponteiro do último bloco processado (`last_scanned_block` salvo no `blockRepo`).
- O polling é feito através do método `processNextChunk`, avançando em blocos (`toBlock = fromBlock + BLOCK_STEP`) e buscando logs na rota POST `/getLogs` da infraestrutura.

### O Ponto Crítico de Falha ("O Limbo")
Apesar de possuir um mecanismo de "Catch-up" razoável (onde se o servidor cair, ele retoma de `fromBlock` salvo no banco de dados) e de uma fila de retentativas (`retryLoop` lidando com até 50 falhas para blocos problemáticos), a raiz da desincronização acontece em três camadas críticas que não conversam harmoniosamente com falhas na rede Polygon:

1. **Separação Abrupta de Estado Jogo-Blockchain:**
   O servidor Kotlin principal (`bombcrypto-server-v2`) marca imediatamente o status do inventário off-chain do jogador como `ItemStatus.Sell` (valor numérico = 2, o "cadeado") **antes mesmo da confirmação On-Chain**. Se o jogador sofre uma falha na sua carteira (ex: gás insuficiente, travamento, erro de RPC) ou no Indexador (atraso de blocos na Polygon), o NFT já sumiu da sua aba ativa do jogo, mas nunca chegou na Market API como uma transação válida.

2. **Exclusões Fantasmas no `detect-transfer`:**
   Existe um projeto utilitário em `bombcrypto-market-v2/detect-transfer` projetado para resolver conflitos de transferência (quando donos transferem NFTs fora do Marketplace para escapar das regras).
   - O `Subscriber` dentro de `detect-transfer/src/core/subscriber.ts` realiza consultas assíncronas no contrato. Se ele não encontrar a ordem listada on-chain ou detectar que a assinatura `ownerOf` não bate, ele executa um Update hardcoded no banco de dados PostgreSQL marcando o pedido como cancelado (`deleted = true`).
   - Isso ocorre sem emitir **nenhum evento de volta (Webhook) para o Game Server em Kotlin**. Logo, a listagem On-Chain some ou é invalidada, a tabela do Marketplace é atualizada, mas o servidor principal continua marcando o NFT como trancado em `ItemStatus.Sell`.

3. **Arquitetura Isolada de Eventos de Sincronia (`listenSyncHero`):**
   A ponte final de notificação do Market API para o jogo usa streams RabbitMQ/Redis processados por `BlockchainResponseManager` no servidor Kotlin (`bombcrypto-server-v2`). No entanto, esses fluxos disparam eventos de "sincronize seu inventário" que dependem da última fotografia (snapshot) que não está ciente do limbo que o `detect-transfer` causou.

**Exemplo do Woodboy:**
Woodboy enviou a ordem de listagem do NFT (sua Villa/House). O servidor de jogo travou a Villa com um cadeado (Status: Sell). A rede Polygon congestionou, ou um erro de aprovação impediu o evento `CreateOrder` de chegar On-Chain.
O script cron job `detect-transfer` leu o banco de dados pendente off-chain do Market, e confirmou On-Chain via API: *"Opa, não vejo esse Order ID no contrato! Deletando do banco de dados do Marketplace"* (`deleted = true`).
A API de Market limpa a "ordem" invisível, **mas o servidor de jogo nunca recebe uma notificação para reverter o `ItemStatus.Sell` para `ItemStatus.Normal`**. Woodboy tenta listar de novo e falha, pois o jogo enxerga que a Villa "não existe", e o cadeado permanece infinitamente.

---

## 3. Lógica de Cadastro/Cadeado no Backend

O backend Game Server (Kotlin) tranca o item atribuindo seu status no enumerador `ItemStatus`.
```kotlin
enum class ItemStatus(val value: Int) {
    Normal(0),
    LockedOrEquipSkin(1),
    Sell(2), // <--- O Cadeado
    Delete(3);
}
```
A mudança para `ItemStatus.Sell` ou o envio ao Marketplace ocorre de maneira otimista pela função `sellV3` em `UserMarketplaceManager.kt`. Quando uma venda concretiza on-chain (evento `Sold`), as mensagens caem em `listenSyncHero`/`listenSyncHouse` no Kotlin.
Porém, se algo for cancelado devido a divergências ou por interferência do serviço `detect-transfer`, o servidor não possui cron jobs de conciliação diária bidirecional para ler se um item marcado como `Sell(2)` tem correspondência válida e real nas tabelas do Marketplace. Falta um mecanismo de re-sincronia forçada sob demanda para destravar itens corrompidos.

---

## 4. Recomendações de Arquitetura Web3 para Curar o Banco de Dados

A arquitetura não deve depender apenas de eventos que "fluem para a frente". É preciso um sistema de verificação cruzada. Recomendo **Jobs de Reconciliação Bidirecional**:

**Recomendação 1: Job de Reconciliação Diário (Bidirectional Reconciliation Cron Job)**
O servidor Game Server (Kotlin) deve ter uma rotina periódica que execute o seguinte loop:
- Busca todos os NFTs com `status = 2 (Sell)` e `status = 1 (Locked)`.
- Realiza um "Sanity Check" no banco de dados do Marketplace. Se o NFT não consta como "Listing" não deletado lá, a rotina força uma destranca devolvendo para `status = 0 (Normal)`.
- Assim, limpa-se instantaneamente todos os jogadores travados como Woodboy sem intervenção manual.

**Recomendação 2: Melhoria no `detect-transfer` (Callback System)**
Atualmente, o `detect-transfer` funciona de forma cega ("atire e esqueça"). Modificar o `markDeleted` no `detect-transfer/src/core/subscriber.ts` para que, além de colocar `deleted = true`, ele também **dispare um evento na fila do RabbitMQ** (ex: `AP_BL_SYNC_CANCEL_RECOVERY`) forçando o servidor Kotlin a receber o aviso e destravar o NFT imediatamente.

**Recomendação 3: Destrancamento sob Demanda pelo Cliente (Botão "Sync")**
Considerar expor um Endpoint no servidor Kotlin (`SyncMyNFTsHandler`) com rate-limiting pesado (ex: a cada 10 minutos). O jogador com erro clica em "Refresh Synced Data" na interface e o servidor consulta diretamente os Smart Contracts via rpc se os NFTs dele estão listados. Se On-Chain o NFT constar como não listado, o cadeado que está preso off-chain cai.

**Arquivo de Origem Culposo no Problema Atual:** `bombcrypto-market-v2/detect-transfer/src/core/subscriber.ts` (função `verifyOrder` falha silenciosamente perante o servidor principal) combinado ao otimismo no Kotlin em `bombcrypto-server-v2/server/BombChainExtension/src/com/senspark/game/manager/UserMarketplaceManager.kt` (`sellV3`).