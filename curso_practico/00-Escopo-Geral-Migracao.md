# Visão Geral da Arquitetura: Migração Sensedia para Kong Konnect

Este documento consolida as estratégias oficiais, mapeando todos os desafios técnicos apresentados pela engenharia da Pottencial (no relatório *"Kong - Estratégia de migração - Overview.pdf"*) diretamente para os laboratórios (cenários) práticos deste Curso.

O objetivo deste roteiro é demonstrar como o **Kong Konnect Enterprise** processa, centraliza e soluciona **com Cero Código (Declarativo e Nativo)** tanto os acertos arquiteturais da equipe quanto os impasses reportados com o legado Sensedia. 

---

## Parte A: Fundamentos e Boas Práticas (Cenários Validados)
A engenharia da Pottencial identificou de maneira excelente o uso de *Expressions* e transformação para o novo roteamento ATC do Kong. Nós encapsulamos essas conquistas nestes laboratórios base:

- 🟢 **[Cenário 03] Roteamento Avançado com Expressions:** Demonstra como a conversão de parâmetros de path (`{product_key}`) mapeados para o motor `KONG_ROUTER_FLAVOR=expressions` elimina a rigidez sem impactar a URL do parceiro externo.
- 🟢 **[Cenário 04] Reescrita de Rotas e Métodos (Path Transformer):** Resolve o desafio do *URI mismatch* introduzindo o nativo `request-transformer` usando a diretiva `replace.uri`.

---

## Parte B: "The Kong Way" (Substituindo a Deuda Técnica de Plugins Lua)
A flexibilidade do Kong Open-Source incentivava a escrita de custom plugins em Lua. No modelo Enterprise (Konnect SaaS), o objetivo é reduzir a zero o código não padronizado para blindar a manutenibilidade. A Pottencial construiu laboratoriamente 3 plugins Lua que são 100% substituíveis pelas funções nativas avançadas:

- 🔄 **Problema:** Plugin `custom-headers` (Injetor de IDs dinâmicos).
  - ✅ **A Solução Oficial:** **[Cenário 05] Substituindo Lua - Transformação de Headers.** Usaremos o nativo `request-transformer`, configurado diretamente nos fluxos para adicionar headers com zero código fonte customizado.
  
- 🔄 **Problema:** Plugin `trace-id` (Mapeador de Correlações).
  - ✅ **A Solução Oficial:** **[Cenário 06] Substituindo Lua - Trace ID e OTLP.** Abordaremos duas missões. Redirecionaremos a carga do Trace Lua para o plugin nativo corporativo `correlation-id`, integrando isso também à necessidade da Pottencial com logs Datadog via `opentelemetry`.

- 🔄 **Problema:** Plugin `oauth-client-credentials` (Integração Gateway-To-Backend Hefesto).
  - ✅ **A Solução Oficial:** **[Cenário 07] Substituindo Lua - M2M OIDC.** Apresentaremos os padrões nativos Enterprise de Machine-to-Machine para Kong atuar como proxy do IDP (buscando credenciais com *Client Credentials Grant*) ou usando *Serverless Functions* isoladas para casos hiper customizados, evitando a gestão de pedaços soltos de Lua.

---

## Parte C: Vencendo as Dificuldades e Impedimentos Legados
A seção de Impedimentos da Pottencial mapeava gargalos arquiteturais graves limitando a transição nativa. Provamos através destes componentes que eles podem ser migrados perfeitamente:

- 🚧 **Dificuldade 1 e 2:** Autenticação dos Consumidores Legados vs OAuth2 Edge e Extracão de Extra Fields.
  - 🏆 **Solução:** **[Cenários 01 e 02] Autenticação e Proxy OIDC (Transparente).** Superamos o impedimento construindo um Proxy Reverso fantasma para o Gateway antigo da Sensedia que se apoia no Identity Provider (Keycloak/Hefesto) e o plugin nativo `openid-connect` para extrair metadados das chaves e gerenciar claims stateless.

- 🚧 **Dificuldade 3:** Controle de Acesso por Consumidor (Restrições de API Individuais).
  - 🏆 **Solução:** **[Cenário 08] Controle de Acesso Por Consumidor (ACL).** Implementamos o plugin nativo `acl` que garante que os consumidores exatos não toquem outras rotas que não possuam credenciais vinculadas explícitas, sem programar uma linha.

- 🚧 **Dificuldade 4:** Proteção Web Global - Prevenção SQL Injection e XSS.
  - 🏆 **Solução:** **[Cenário 09] Proteção Web (WAF e Request Validator).** O Kong não desampara o cluster contra ataques OWASP. Mostraremos as opções de sanitização globais nativas como Kong Upstream WAF ou configurações de inibição de payload via plugin `request-validator`.

> [!TIP]
> Proceda ordem por ordem abrindo as pastas listadas no roteiro e leia seus Markdown instrucionais para assimilar o verdadeiro Poder do OIDC e da Arquitetura do Kong Konnect Enterprise.
