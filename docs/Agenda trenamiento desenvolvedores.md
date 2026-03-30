**Treinamento Intensivo para Desenvolvedores: Migração Sensedia para Kong Enterprise**

**Duração Total:** 8 horas (pode ser dividido em 2 sessões de 4 horas ou 1 diária completa).
**Público-alvo:** Desenvolvedores backend, integradores e desenvolvedores de APIs.
**Objetivo:** Introduzir a plataforma Kong Konnect, montar um ambiente de trabalho funcional e resolver de forma nativa todos os desafios técnicos mapeados na migração da Sensedia (gestão de tokens, controle de acesso, segurança WAF e substituição de scripts Lua).

---

### **Pré-requisitos**
Para a execução prática, cada desenvolvedor deverá contar com:
*   **Git** instalado para clonar o repositório base.
*   **Docker Desktop** (ou Docker Engine + Compose v2) rodando localmente para provisionar os simuladores (mocks), o Gateway e a interface visual do Jaeger.
*   **CLI do Kong (decK)** instalada para aplicar configurações de forma puramente declarativa.
*   **Acesso à Internet** liberado para comunicação segura (Outbound TLS) pela porta 443 com o Control Plane do Kong Konnect (SaaS).

---

### **Agenda do Treinamento (8 Horas)**

#### **Módulo 1: Introdução ao Konnect e Setup do Ambiente (2 horas)**
*   **Conceitos Base:** Introdução ao modelo de operação do Kong Konnect, compreendendo a separação arquitetural entre o Control Plane (SaaS) e o Data Plane.
*   **Setup Prático:** Deploy de um Data Plane local híbrido usando Docker Compose, integrado diretamente ao Control Plane SaaS corporativo.
*   **Emulação do Ambiente:** Integração do Gateway com servidores de eco (Mocks de Backend), Jaeger (para visualização de traces emulando o Datadog) e Keycloak (simulando localmente o Identity Provider interno *Hefesto*).

#### **Módulo 2: Motor Avançado de Roteamento e Expressions (1.5 horas)**
*   **Roteamento Declarativo:** Uso da CLI `decK` para gerenciar e sincronizar rotas e serviços, substituindo as configurações manuais do antigo gateway.
*   **Motor ATC e Regex:** Resolução nativa da captura de parâmetros dinâmicos complexos na URL (por exemplo, extrair `{product_key}` do path). Utilizaremos o potente motor de *Expressions* do Kong para padronizar as rotas e garantir compatibilidade exata com os endpoints atuais.

#### **Módulo 3: Autenticação e Estratégia Zero-Atrito para Tokens Legados (1.5 horas)**
*   **Proxy OIDC e Hefesto:** Abordaremos a substituição do plugin OAuth2 da Sensedia. Configuraremos o Gateway como um proxy transparente usando o plugin nativo `openid-connect` para integração com o Hefesto, extraindo *claims* e validando identidades sem a necessidade de código customizado.
*   **Estratégia Zero-Atrito:** Implementação de duas alternativas para garantir que a migração seja imperceptível para os clientes (sem forçar reautenticações):
    1.  **Validação Stateless:** Validação local e em tempo real dos JWTs atuais preexistentes, apontando a assinatura criptográfica diretamente para o Auth Server.
    2.  **Importação em Massa (Seed):** Uso da API Admin do Kong para injetar *access_tokens* opacos herdados da base da Sensedia (mantendo seus tempos de expiração), permitindo às aplicações continuarem enviando o mesmo header `Authorization: Bearer`.

#### **Módulo 4: Segurança Web e Controle de Acesso Granular (1.5 horas)**
*   **Isolamento de Rotas por Consumidor:** Resolução da restrição de APIs individuais. Implementaremos Listas de Controle de Acesso nativas (*ACL*) em conjunto com o plugin `key-auth` para negar requisições a um token válido caso tal consumidor não pertença ao grupo autorizado para uma rota específica.
*   **Proteção Edge WAF:** Substituição dos interceptadores globais da Sensedia contra injeções SQL (SQLi) e Cross-Site Scripting (XSS). Aplicaremos o plugin `request-validator` diretamente na borda para bloquear automaticamente cargas úteis maliciosas com um HTTP 400 Bad Request, garantindo a segurança sem lógicas customizadas.

#### **Módulo 5: Eliminação de Dívida Técnica e Observabilidade (1.5 horas)**
*   **O "Kong-Way" (Substituindo scripts Lua):** Demonstração prática de como reduzir o esforço estimado de reescrever scripts herdados (calculado previamente em mais de 25 dias) utilizando exclusivamente plugins nativos do Konnect:
    *   **Transformação de Headers e Payload:** Uso avançado do plugin `request-transformer` para manipular e injetar identificadores posicionais (como mapear `{product_key}` para o header `x-product-key`) de forma automatizada.
    *   **Identidade M2M:** Implementação do padrão *Relying Party* para obter tokens Machine-to-Machine e despachá-los para serviços financeiros internos.
*   **Observabilidade e Tracing:** Substituição do plugin Lua de `trace-id`. Injetaremos identificadores padrão do W3C (`correlation-id` e `traceparent`) e exportaremos os traces em formato OTLP usando o plugin `opentelemetry` para o agente do Datadog/Jaeger, alcançando visibilidade completa sem instrumentação paralela.
*   **Q&A e Encerramento:** Modelagem geral do deploy massivo e automatizado para os ambientes de produção.