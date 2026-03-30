# Capítulo 02: Estratégia de Migração Sensedia com Zero Impacto

Ao migrar da plataforma legada **Sensedia** para a arquitetura Gateway distribuída do **Kong Konnect**, enfrentamos o desafio arquitetônico mais comum de migração: **Como não quebrar os clientes atuais?**

Na Sensedia, o próprio API Gateway atuava equivocadamente como um Banco de Dados/IDP, responsabilizando-se por:
1. **Emissão Numérica de Tokens** via `POST /oauth/v3/access-token`.
2. **Armazenamento de Propriedades de Consumidor** (como _flags_ de negócio e _identificadores internos_ amarrados a chaves locais).

> [!IMPORTANT]
> **A Estratégia de Migração Transparente para Konnect**
> O Kong Konnect segue arquitetura Cloud-Native e delega nativamente a emissão de tokens. Para migrar da Sensedia com **Zero Impacto** e evitar refatorar os clientes, empregaremos o modelo de **Proxy Transparente OIDC com Stateless Claims**.
>
> 1. **Zero Mudanças de Rota (Proxy reverso):** Ensinaremos o Kong a mentir e mapear a exata rota antiga (`/oauth/v3/access-token`). Os clientes das APIs continuarão disparando requisições contra a mesma URL e payload local (achando que o Gateway ainda gera tokens).
> 2. **Delegação para o Hefesto (IDP):** O Kong enviará essa chamada escondida, como um proxy pass, para o seu verdadeiro IDP Corporativo (no caso da Pottencial, o **Hefesto** — que neste laboratório **está sendo simulado pelo Keycloak local**).
> 3. **A Solução para "Extra Fields" (Metadados Customizados):** Em vez de acoplar as *flags de acesso* ou *ID's internos* no Gateway local (o problema do Sensedia), o **Hefesto** inyectará estrategicamente essas propriedades legadas dentro do JSON Payload do Access Token (JWT).
> 4. **Tradução na Borda (Edge):** O Kong utilizará o plugin `openid-connect` para abrir esse token instantaneamente na borda (sem chamadas a bancos de dados externos), ler as propriedades adicionais que o *Hefesto* guardou, transmutando tudo em limpos **Headers HTTP** (`X-Sensedia-...`) para alimentar seu backend como de costume!

---

## 1. Configurando o Identity Provider (Keycloak) Localmente

Criamos um script que injeta as **Propriedades Adicionais (Claims)** exatamente como eram guardadas na Sensedia, mas agora embutidas direto na Configuração de Cliente do Keycloak:

1. Execute o script `setup-keycloak.sh`:
```bash
chmod +x setup-keycloak.sh
./setup-keycloak.sh
```
*Ele criará um Realm `pottencial`, o Client da aplicação `app-pottencial` e, de forma essencial, **Mappers** que injetarão as `sensedia_access_flags` direto na carga do token final.*

---

## 2. Declarando a Topologia Proxy e OIDC no decK

Usaremos as bibliotecas declarativas do Kong para montar a arquitetura completa:
1. Cadastrar a nova rota `sensedia-token-proxy` mapeada para a exata URL antiga (`/oauth/v3/access-token`), redirecionando os clientes ocultamente para o Keycloak real na sua rede interna.
2. Ativar o plugin enterprise `openid-connect` na nossa API Financeira, configurado para extrair através do campo `upstream_headers_claims` os _clusters de claims customizados_ gerados pelo Keycloak.
3. Cadastrar o Consumidor (`App_Pottencial`) para rastreabilidade de negócio.

Configure ou verifique seu `02-auth.yaml`:
```yaml
_format_version: "3.0"
services:
- name: insurance-api
  url: http://host.docker.internal:8080
  routes:
  - name: secure-api-route
    paths:
    - /insurance/v2
    preserve_host: false
    strip_path: false
    plugins:
    - name: openid-connect
      config:
        issuer: "http://host.docker.internal:8081/realms/pottencial"
        auth_methods: ["bearer"]
        consumer_claim: ["client_id"]
        scopes_required: ["profile"]
        upstream_headers_claims:
        - "sensedia_access_flags"
        - "sensedia_internal_identifier"

- name: keycloak-token-service
  url: http://host.docker.internal:8081/realms/pottencial/protocol/openid-connect/token
  routes:
  - name: sensedia-token-proxy
    paths:
    - /oauth/v3/access-token
    preserve_host: false
    strip_path: true
    # Proxy Pass-through puro para a requisição de credenciais antigas Sensedia

consumers:
- username: App_Pottencial
  custom_id: "app-pottencial"
```

---

## 3. Sincronizando o Ambiente no Konnect

Aplique as mudanças de infraestrutura:
```bash
deck gateway sync 02-auth.yaml --konnect-token $KONNECT_TOKEN --konnect-addr $KONNECT_ADDR --konnect-control-plane-name "$CONTROL_PLANE_NAME"
```

Valide que a área principal está protegida corretamente pela borda (OIDC):
```bash
curl -i http://localhost:8000/insurance/v2/rota-fechada
# Deve retornar HTTP 401 Unauthorized
```

---

## 4. Teste End-to-End: Simulando o Cliente da Aplicação

### **A.** Solicitar Token via Endpoint Antigo Sensedia (Mock)
A grande mágica da migração! Como o Kong montou o Proxy Reverso mascarando o Identity Provider, o seu consumidor backend ainda solicita tokens como ele está acostumado `[1]`:
```bash
# Observe que enviamos estritamente para o localhost:8000 (Kong Data Plane)
# e mantemos o "Host" falsificado para o Keycloak assinar corretamente:
TOKEN=$(curl -s -X POST http://localhost:8000/oauth/v3/access-token \
  -H "Host: host.docker.internal:8081" \
  -d "grant_type=client_credentials" \
  -d "client_id=app-pottencial" \
  -d "client_secret=SECRET_MUITO_SECRETO" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)

echo "✅ Novo Token Recebido via Gateway!"
```

_[1] O parâmetro `-H "Host..."` é exigido apenas localmente por restrições dos Docker Networks Mac (para a assinatura bater com o Issuer da descoberta OIDC). Em um DNS real Enterprise não é necessário._

### **B.** Consume a Rota recebendo os Flags Originais Exfiltrados
O último e mais importante passo. Execute a requisição final usando a chave gerada:
```bash
curl -i -X GET http://localhost:8000/insurance/v2/rota-fechada \
  -H "Authorization: Bearer $TOKEN"
```

**Confira a resposta HTTP vinda do Echo Server**.
Você observará nas propriedades (`"headers"`) que o plugin não só autenticou o cliente sem lag, como varreu o token na exfiltração JWT e preencheu as informações que o backend antigo exigia magicamente injetadas nos Headers HTTP puros (Stateless properties):
```json
"x-sensedia-flags": "PREMIUM,VIP,MIGRATED",
"x-sensedia-id": "APP-998877",
"x-consumer-custom-id": "app-pottencial"
```
Missão de Migração e Refatoração cumprida!

---

### **C. Executando o Cliente Mock Automático (Python)**

Para facilitar a demonstração visual desta arquitetura para outros times e para a diretoria, criamos um script de "Prova Final" chamado `cliente_sensedia_mock.py`. Ele simula exatamente o comportamento da aplicação Sensedia de forma gráfica.

Sendo um ambiente MacOS ou Linux, utilize o comando nativo `python3` no seu terminal:
```bash
python3 cliente_sensedia_mock.py
```
*(Se preferir, o script já possui permissão de execução em sistemas Unix, bastando rodar `./cliente_sensedia_mock.py`)*

O script executará automaticamente as duas fases (A e B) e imprimirá de forma colorida e clara os payloads e os Headers injetados. É a prova definitiva de que o Kong Konnect gerencia o fluxo legado com maestria!
