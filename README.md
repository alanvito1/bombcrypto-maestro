# 🚀 BombCrypto Maestro Ecosystem

Bem-vindo ao **Maestro**, a camada de orquestração zero-touch projetada para inicializar todo o ecossistema BombCrypto localmente, em modo offline e sem dependências externas.

## 🏗️ Arquitetura Port-Mapped (Safe Range)

Todos os serviços foram mapeados para evitar conflitos com o sistema operacional e garantir total harmonia entre os containers.

| Serviço | Porta Interna | Porta Externa (Local) | Notas |
| :--- | :--- | :--- | :--- |
| **Market Portal (UI)** | 4005 | **4005** | Interface de compra/venda |
| **TH Mode (UI)** | 4006 | **4006** | Interface Treasure Hunt |
| **PostgreSQL** | 5432 | **5433** | DB compartilhado (Market, Game, Login) |
| **Redis** | 6379 | **6381** | Cache e Streams |
| **SmartFoxServer** | 9933 | **9933** | Servidor de Jogo (TCP/UDP) |
| **Blockchain Center API**| 3005 | **3005** | Mock de rede RPC |
| **Market Backend** | 3007 | **3007** | Lógica do Marketplace |
| **Login API** | 8006 | **8006** | Autenticação centralizada |
| **TH Server (Backend)** | 8106 | **8106** | Lógica Treasure Hunt |

---

## 🚀 Como Iniciar

1.  **Pré-requisitos**:
    - Docker Desktop instalado e rodando.
    - Submódulos atualizados (`git submodule update --init --recursive`).

2.  **Subir o Ecossistema**:
    No diretório raiz (`C:\bomb`), execute:
    ```bash
    docker compose up -d
    ```

3.  **Verificar Inicialização**:
    Acompanhe os logs para garantir que os esquemas do Postgres foram aplicados corretamente:
    ```bash
    docker compose logs -f db
    ```

4.  **Acesso**:
    - Marketplace: [http://localhost:4005](http://localhost:4005)
    - Treasure Hunt: [http://localhost:4006](http://localhost:4006)
    - RPC Status: [http://localhost:3005/status](http://localhost:3005/status)

---

## 🛠️ Configurações Customizadas (`maestro.env`)

A orquestração utiliza o arquivo central `maestro.env` na raiz. Alterar configurações aqui afetará todos os containers automaticamente, sem precisar editar os arquivos internos dos submódulos.

- **Offline Mode**: `USE_MOCK_DATA=true` está ativo por padrão.
- **DBs Automáticos**: O script `init-maestro-db.sh` cria automaticamente os bancos `market`, `bombcrypto` e `bombcrypto2`.

---

## 🎮 Conectando o Cliente Unity (WebGL)

O cliente WebGL deve ser configurado para apontar para os seguintes endpoints locais:

- **SmartFox Server**: `localhost` na porta `9933`.
- **Market API**: `http://localhost:3007`.
- **Treasure Hunt API**: `http://localhost:3006`.

*Nota: Se estiver rodando o build WebGL fora do Docker, mude os endpoints conforme as portas mapeadas acima.*

---

**Equipe Antigravity - Arquitetura Impecável 2026**
