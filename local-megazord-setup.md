# Relatório de Auditoria de Infraestrutura e Setup Local: "O Megazord"

## 1. Mapeamento de Dependências (Bancos e Infra)

### Bancos de Dados Exigidos
O ecossistema exige dois bancos de dados para rodar localmente:
1. **PostgreSQL**: Utilizado para gerenciar os dados relacionais do jogo (Server V2) e do Market V2.
2. **Redis**: Utilizado para cache e mensageria entre os serviços.

### Docker Compose
**Sim, existe um `docker-compose.yml` global** na raiz do projeto principal (`/bomb`). Ele já orquestra tanto o Postgres (versão 17) quanto o Redis (versão 8), expondo-os nas portas padrão `5432` e `6379`, respectivamente. Além disso, há o script `init-db.sh` no `docker-compose` para criar as databases `backend` e `bombcrypto2`, e rodar as migrações iniciais (schema, init, season_1 e mock do first_user) que estão contidas em `bombcrypto-server-v2/server/db/`.

### Inicialização do SmartFoxServer (server-v2)
O SmartFoxServer **NÃO** está mockado. Ele é inicializado em um container Docker real, construído a partir do `bombcrypto-server-v2/server/deploy/Dockerfile.arm64`. O container `sfs-game-1` carrega a configuração via `bombcrypto-server-v2/server/.env` e mapeia volumes essenciais do SmartFox localmente (patches, extensions e client logs). Ele expõe várias portas, como a `8080` (HTTP/WebSocket) e `9933` (TCP/UDP socket do game client).

## 2. Sequência de Startup (Os Motores)

### Comandos da API do Market (`blockchain-center-api` e `detect-transfer`)
O repositório do Market V2 roda 3 serviços backend vitais:
1. **Market API** (`bombcrypto-market-v2/backend`):
   - Comando executado no docker: `npm install && npm run dev:api:bsc`
2. **Detect Transfer** (`bombcrypto-market-v2/detect-transfer`):
   - Comando executado no docker: `npm install && npm run dev`
3. **Blockchain Center API** (`bombcrypto-market-v2/blockchain-center-api`):
   - Comando executado no docker: `npm install && npx nodemon server.js`

### Comando do Client (`unity-web-template`)
O client Unity (especificamente o WebGL template) não está orquestrado no `docker-compose.yml` atual. Ele depende do build/dev script de Vite contido no `bombcrypto-client-v2/unity-web-template/package.json`.
- Comando para inicializar o ambiente de dev do Client (WebGL Vite dev server): `npm run start` (ou seja, `vite`).

*Nota: Isso deve ser executado com Node, no entanto, é preciso primeiro buildar o WebGL via editor da Unity na pasta configurada (`VITE_UNITY_FOLDER`). O cliente depende do Server rodando localmente para completar o login.*

### Dependência da Blockchain (Smart Contracts)
A dependência da blockchain **foi resolvida usando um Node Hardhat local**.
Dentro do `docker-compose.yml` existe o serviço `hardhat-node` apontando para o sub-repositório `bombcrypto-contract-v2/base-hardhat`.
O comando executado no container é `npm install && npx hardhat node`, que levanta a chain local do Hardhat rodando na porta `8545`. As variáveis de ambiente de todo o ecossistema são instruídas via scripts (`init-bomb.sh` e `setup.bat`) para apontarem para `http://bombcrypto-hardhat:8545` ou `http://localhost:8545`.

## 3. Avaliação do "One-Click Boot"

**Existe atualmente uma forma de rodar tudo com um único comando?**
**Parcialmente sim.**
Na raiz do projeto, temos os scripts `init-bomb.sh` e `setup.bat` (além de um `docker-compose.yml` muito robusto). Ao rodar `./init-bomb.sh`, ele propaga os arquivos `.env.example` para `.env` em todos os diretórios do projeto e orienta que o dev suba toda a stack executando `docker compose up -d`.

Isso levanta a seguinte infraestrutura quase completa:
- Postgres (com seeds iniciais) e Redis.
- Hardhat Node (Ethereum local).
- Backend Authentication e Market (AP-Login e AP-Market).
- SmartFox Game Server (SFS2X com código Kotlin).
- Market Frontend (Vite) e as API/Subscribers do Market (Market API, Detect Transfer, e Blockchain Center).

**No entanto, para termos um "Megazord" perfeito e um "One-Click Boot" real, faltam alguns ajustes:**

### Passos para criar um `start-megazord.sh` definitivo:

1. **Client Unity Frontend Integrado:**
   Atualmente o `docker-compose.yml` levanta tudo *exceto* o dev server do client. Precisamos adicionar um serviço no `docker-compose.yml` para rodar o Vite dev server do Client:
   ```yaml
   client-webgl:
     image: node:22-bullseye
     container_name: bombcrypto-client
     working_dir: /app
     volumes:
       - ./bombcrypto-client-v2/unity-web-template:/app
       - client_node_modules:/app/node_modules
     command: sh -c "npm install && npm run start"
     ports:
       - "5174:5173" # Expor na porta 5174 local para não conflitar com o Market Frontend
   ```
   *(Nota: Exige que o WebGL tenha sido devidamente buildado no Editor Unity).*

2. **Sincronização Segura de Secrets (.env):**
   O script `init-bomb.sh` funciona copiando cegamente `.env.example` para `.env`.
   Isso é arriscado porque as chaves de criptografia e assinaturas de Login (`JWT_BEARER_SECRET`, `AP_LOGIN_TOKEN`, `AES_SECRET`, etc.) devem ser **idênticas** entre o Ap-Login, Ap-Market, SmartFox Game Server, e Unity Client.
   O `start-megazord.sh` deve garantir a geração (ou sobreposição forçada) dessas variáveis compartilhadas.

3. **Deploy Automático dos Contratos (Hardhat):**
   Apesar do container `hardhat-node` subir a blockchain, ele não faz o "deploy" inicial dos contratos (BCOIN, Heróis, Market, etc) automaticamente nessa rede para que os testes comecem. O `start-megazord.sh` deve aguardar a porta 8545 estar pronta e rodar um comando (ex: `npx hardhat run scripts/deploy.js --network localhost`) injetando os endereços gerados nos `.env` do Backend.

4. **Script Sugerido (`start-megazord.sh`):**
   ```bash
   #!/bin/bash
   echo "🚀 Iniciando inicialização Megazord Bomb Crypto V2..."

   # 1. Preparar .env (Cópia inteligente + validação de segredos sincronizados)
   ./init-bomb.sh

   # 2. Subir Bancos, Hardhat, Backend Node.JS e SFS Game Server
   docker compose up -d

   # 3. Aguardar Hardhat (porta 8545) estar saudável
   echo "⏳ Aguardando blockchain local..."
   sleep 5 # (Pode ser substituído por um ping/curl na porta 8545)

   # 4. (Futuro) Deploy dos Contratos
   # docker exec bombcrypto-hardhat sh -c "npx hardhat run scripts/deployAll.js --network localhost"

   # 5. Levantar o Dev Server do Unity WebGL Client
   echo "🎮 O Client estará disponível em http://localhost:5174"
   echo "🌐 O Market estará disponível em http://localhost:5173"
   echo "✅ Ambiente pronto! Verifique os logs com 'docker compose logs -f'"
   ```

### Conclusão e Testes de Gameplay (PvP e Adventure):
Com a arquitetura analisada, **a Senspark deixou uma infraestrutura local excelente**. Se o Founder quiser testar o Gameplay hoje:
- Ele precisará executar o `./init-bomb.sh` e o `docker compose up -d`.
- Verificar se o build WebGL (`bombcrypto-client-v2/unity-web-template`) está atualizado com o seu Editor da Unity, apontando para as chaves secretas listadas no `AppConfig.json` e no `.env` do web-template.
- Iniciar o Vite Frontend do Client.
Como o Postgres já é importado com dados de *mock* via `/first_user_add_data.sql`, o modo Adventure poderá ser testado diretamente com os heróis pre-inseridos na tabela do DB local associados a carteira de teste que o client injetar.