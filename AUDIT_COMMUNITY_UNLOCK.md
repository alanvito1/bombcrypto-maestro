# AUDIT COMMUNITY UNLOCK: Infinite Inventory Impact

Esta auditoria detalha o impacto em cascata nos submódulos devido à remoção das travas de limite de inventário e à introdução da função `batchTransfer`. O cenário de estresse validado é de **10.000 NFTs por carteira**, focando em *Heróis* (`BHeroToken`) e *Casas* (`BHouseToken`).

---

## 1. Submódulo `bombcrypto-server-v2` (Backend)

**Gargalo Identificado:**
Atualmente, no momento de carregamento inicial (login ou resync), o servidor efetua uma busca completa (fetch integral) de todos os Heróis e Casas da base de dados, instanciando cada um em memória na forma de `ConcurrentHashMap` por usuário, o que sem dúvida resultará em *timeout* ou estouro de memória (Out Of Memory - OOM) quando um usuário possuir milhares (ex: 10.000) de NFTs.

**Onde Procurar (Arquivos e Linhas):**
* `bombcrypto-server-v2/server/BombChainExtension/src/com/senspark/game/db/GameDataAccessPostgreSql.kt`
  * Linhas 47-60: Função `getFiHeroes`. A query `SELECT ub.* ... FROM "user_bomber"` não possui limites nativos de paginação (`LIMIT`/`OFFSET`).
  * Linhas 547-560: Função `loadUserHouse`. Semelhante aos heróis, as casas também são trazidas de forma integral da base de dados.
* `bombcrypto-server-v2/server/BombChainExtension/src/com/senspark/game/manager/hero/UserHeroFiManager.kt`
  * Linhas 93-124: Função `loadBomberMan()`. Aqui a lista inteira de heróis do usuário é instanciada na memória local do servidor (`_items.putAll(data)`), guardando um mapa massivo.
* `bombcrypto-server-v2/server/BombChainExtension/src/com/senspark/game/controller/UserHouseManager.kt`
  * Linhas 48-54: Função `getItems()`. Instancia todas as casas do BD na memória.

**Sugestão Arquitetural (Actionable):**
* **Paginação de Banco de Dados:** Refatorar as queries SQL (`getFiHeroes`, `loadUserHouse`) para aceitar paginação (Cursor-based ou `LIMIT/OFFSET`).
* **Lazy Loading em Memória:** Modificar as classes de Manager (`UserHeroFiManager`, `UserHouseManager`) para carregar apenas uma página ativa (ou chunks, ex: 100 heróis por vez) a serem cacheados.

---

## 2. Submódulo `bombcrypto-client-v2` (Frontend Unity)

**Gargalo Identificado:**
O componente de inventário da Unity (`DialogInventory`) atualmente realiza uma instancição direta massiva (`Instantiate`) de todos os *prefabs* da página renderizada em uma grade (*grid*). Apesar do código ter a flag `_verticalDynamicScroll`, os objetos ainda são destruídos e instanciados nas transições (e por vezes, desativados em loops pesados), criando travamentos monstruosos (ou a temida *tela preta*) ao transitar por uma UI que tenha de instanciar milhares de objetos, devido ao sobrecarregamento na *main thread* da Unity e no Garbage Collector.

**Onde Procurar (Arquivos e Linhas):**
* `bombcrypto-client-v2/Assets/Scenes/FarmingScene/Scripts/DialogInventory.cs`
  * Linhas 323-437: Função `InstantiateItems`. Em `var item = Instantiate(inventoryItemPrefab, parent, false);`, o script itera e instancializa *prefabs* visualmente. O código até tem um aviso: *Fix Me: deletar itens temporários*, indicando problemas passados de renderização pesada.
  * Linha 180: Uso incompleto/restrito de `DynamicScroll<DynamicInventoryItem, DynamicObject> _verticalDynamicScroll`. A virtualização atual não está preparada para uma escala contínua e fluida de 10.000 itens se limitando a renderizar e deletar páginas no DOM virtual.

**Sugestão Arquitetural (Actionable):**
* **UI Virtualization Verdadeira (Native Unity):** Adotar uma lista ou *grid* virtual onde os objetos UI são reaproveitados ativamente ao dar scroll.
* **Object Pooling Estrito:** Nunca invocar `Instantiate` ou `Destroy` durante a abertura ou a rolagem do inventário; criar um *pool* inicial com base no tamanho da tela (ex: 20-30 prefabs) e atualizar exclusivamente os dados (texturas/stats) ao receber o evento de *scroll*, ativando/desativando apenas os necessários de forma *lazy*.

---

## 3. Submódulo `bombcrypto-market-v2` (Frontend Market)

**Gargalo Identificado:**
O frontend do mercado foi inteiramente desenhado ao redor de contratos estritos de 1-para-1. As transações de *listing*, compra ou transferência estão operando em um token individual por transação, disparando chamadas de contrato onerosas unitariamente. Para o suporte ao "Infinito", o Market precisa alavancar interações de rede em massa.

**Onde Procurar (Arquivos e Linhas):**
* `bombcrypto-market-v2/frontend/src/context/smc.tsx`
  * Linhas 214-226: Função `createOrder`. Usa `InstanceHeroMarket?.createOrder(id, ...)` chamando uma API *smart contract* por NFT individual (BHero).
  * Linhas 327-340: Função `createOrderBhouse`. Executa o mesmo padrão de apenas 1 ID para as Casas.
  * *Global:* As funções `buyOrder` e transferências diretas só aceitam IDs singulares. Ausência da conexão com a nova função global `batchTransfer`.

**Sugestão Arquitetural (Actionable):**
* **Conexão Web3 Batching:** O *contexto SMC* precisa ser refatorado para suportar arrays (`uint256[]`) conectando as chamadas UI (onde o usuário poderia dar um "Select All" ou "Select Multiple") à nova função do contrato `batchTransfer` ou `batchCreateOrder` (caso o market contract seja atualizado), consolidando centenas de *approvals* e *transfers* em um único payload de RPC por transação Web3. Em UI, adaptar modais de *Sell* e *Transfer* para aceitarem múltiplas seleções de forma paginada para listar de uma só vez.
