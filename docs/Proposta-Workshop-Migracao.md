# Proposta de Workshop de Engenharia: Rota de Migração Sensedia para Kong Enterprise

**Documento de Resposta ao Relatório:** *"Kong - Estratégia de migração - Overview.pdf"*

Prezados engenheiros e arquitetos da Pottencial,

Agradecemos o envio detalhado do mapeamento arquitetural atual de vocês. Com base nos acertos técnicos mencionados, na estratégia de componentes Lua que vocês desenvolveram e, principalmente, nos bloqueios narrados na seção de "Dificuldades e Impedimentos", preparamos uma sessão de **Workshop Técnico Prático (Hands-on)**. 

O objetivo desta sessão é construir, junto com vocês, o ambiente e demonstrar na prática como o **Kong Konnect Enterprise** resolve nativamente (de forma totalmente declarativa, sem a necessidade de custom scripts) todos os pontos levantados no documento original.

Abaixo está o roteiro, a metodologia e os requisitos do nosso Workshop planejado.

---

## Pré-requisitos Técnicos
Para garantir um fluxo contínuo durante a sessão técnica, solicitamos que cada engenheiro participante tenha em sua máquina local:

* **Git** instalado para clonar o repositório do curso.
* **Docker Desktop** (ou Docker Engine + Docker Compose v2) rodando localmente para provisionar os mocks, o Gateway e a interface visual do Jaeger.
* **CLI do Kong (decK)** instalada para aplicar as configurações de forma puramente declarativa.
* **Acesso à Internet** liberado para comunicação segura (`Outbound TLS`) com o Control Plane do Kong Konnect (SaaS) na porta `443`.

---

## Fase 1: Setup do Ambiente Local (Hands-on)

Para garantir que o time de vocês ganhe autonomia e explore a plataforma em tempo real durante a nossa call, a primeira parte do workshop será focada na construção do ambiente de cada engenheiro.

* **Objetivo:** Subir um Data Plane local isolado integrado ao Control Plane do Kong Konnect SaaS.
* **Componentes Locais:** Servidores de Eco (Mocks de Backend), Identity Provider simulado (Keycloak substituindo localmente o *Hefesto*) e Jaeger (substituindo visões da *Datadog*).
* **Método:** Executaremos juntos as instruções de Setup via Docker Compose disponibilizadas previamente pela nossa equipe, garantindo que todos tenham um Gateway plenamente funcional antes de iniciarmos os cenários práticos.

---

## Fase 2: Laboratórios Práticos (Mapeamento de Impedimentos)

Uma vez que o ambiente de todos estiver rodando de forma sincronizada, percorreremos a bateria de laboratórios abaixo. Cada cenário abordado foi construído exclusivamente para responder a uma dor exata listada no seu PDF estratégico.

### Bloco A: Superando as "Dificuldades e Impedimentos" (A Missão Crítica)
Este bloco resolve os desafios sistêmicos que o time de vocês classificou como bloqueios.

* **Dificuldade 1 e 2 mapeadas (Tokens Legados e Campos Extras na Autenticação):**
  * 🟢 **Cenário 01 e 02: Autenticação Proxy e OIDC:** Vocês aprenderão a configurar um "*Proxy Ghost*" que gerencia todo o ciclo de vida dos tokens Sensedia obsoletos usando o plugin nativo `openid-connect`. Provamos que o Gateway pode interagir de maneira totalmente transparente no modelo de Proxy e extrair *claims* sem uma linha de código.

* **Dificuldade 3 mapeada (Restrições individuais de APIs):**
  * 🟢 **Cenário 08: Controle de Acesso Por Consumidor (ACL Nativo):** Em resposta direta ao questionamento de como isolar rotas para um consumidor sem programação pesada, construímos o cenário de *Access Control Lists* aliado a `key-auth`. Veremos na prática como negar o acesso de um token válido só porque ele não pertence ao grupo delimitado para aquela rota.

* **Dificuldade 4 mapeada (Prevenção de SQLi e XSS):**
  * 🟢 **Cenário 09: Proteção Web Global (WAF & Schema):** Resolvendo a proteção na borda (Edge Protection), demonstraremos testes de injeção em payloads e aplicaremos o `request-validator` para bloquear sujeira (`HTTP 400 Bad Request`) perfeitamente, garantindo integridade de sistemas transacionais sem código extra.

### Bloco B: O "Kong-Way" (Solucionando a Dívida Técnica de Plugins Lua)
Notamos que, visando preencher lacunas, a equipe de vocês desenvolveu 3 plugins dedicados em Lua. Com o Kong Enterprise, abstrairemos essa necessidade de sustentação.

* **Impedimento (Plugin Mapeador Custom Headers):**
  * 🔄 **Cenário 05: Substituindo Lua - Transformação de Headers.** Transformaremos essa lógica antiga implementando `request-transformer` de ponta a ponta na rota, repassando identificadores dinâmicos ao upstream local de teste.

* **Impedimento (Plugin de Trace ID Customizado):**
  * 🔄 **Cenário 06: Substituindo Lua - Trace ID e Correlação OTLP.** Injetaremos IDs usando `correlation-id` e `traceparent` do W3C W3C via plugin genérico, despachando tudo via Agente para os Painéis Visuais demonstrativos sem codificação Lua paralela.

* **Impedimento (Plugin de Client Credentials M2M - Hefesto):**
  * 🔄 **Cenário 07: Substituindo Lua - M2M e OIDC Outbound.** Mostramos o modelo Kong Nativo para o Gateway extrair (Relying Party) um Token provido por M2M validado e inserido na requisição que segue ao seu servidor financeiro.

### Bloco C: Adoção de Motor Avançado (Aproveitando as Boas Práticas)
* **Comentário Positivo mapeado (Motor ATC):**
  * 🎯 **Cenário 03 e 04: Roteamento Avançado e Reescrita (Expressions).** Confirmaremos a excelente decisão técnica de vocês com *Expressions* usando `product_keys` via regex robustos de borda em nossa estrutura final de sincronia pelo sistema *decK*.

---

## Agenda Sugerida (Duração Estimada: 2h 30m)

Para fins de alinhamento de calendário, propomos a seguinte gestão do tempo da sessão para executarmos todas as fases:

* **00m – 15m (15m):** Boas-vindas, alinhamento estratégico e diagramação da arquitetura (Control Plane SaaS vs Data Plane Local).
* **15m – 45m (30m):** Fase 1: Git Clone, `docker compose up`, provisionamento do Data Plane local e teste de Echo-Server.
* **45m – 85m (40m):** Fase 2 (Bloco A): Quebrando Dificuldades. Mapeamento Sensedia Legacy (Proxy OIDC) e Políticas de Segurança (ACL por Consumidor + WAF).
* **85m – 95m (10m):** *Intervalo (Break).*
* **95m – 130m (35m):** Fase 2 (Blocos B e C): Morte da Dívida Técnica. Substituindo Lua Scripts (Transformações, Telemetria OTLP no Jaeger visual, e M2M Identity) mais ATC Routing.
* **130m – 150m (20m):** Q&A livre (Perguntas e Respostas), discussão de design para produção e encerramento.

---

Aguardamos agendas da equipe técnica para realizar o convite de apresentação oficial e seguirmos juntos com o roteiro de Setup.
