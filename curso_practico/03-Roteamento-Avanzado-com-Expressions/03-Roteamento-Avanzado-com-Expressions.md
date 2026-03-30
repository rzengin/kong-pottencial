# Capítulo 03: Roteamento Avançado com Expressions

No Kong Gateway, o Router Engine padrão (tradicional) suporta casamento de padrões e URIs básicos. Mas quando lidamos com lógicas legadas ou de migração, como no mapeamento da Pottencial (p. ex., converter `{product_key}` dinamicamente dentro do `URI`), precisamos de alto nível de granularidade usando a nova engine: **Router Expressions** (baseada em estilo Rust/SQL).

### O Cenário do Legacy (Pottencial Seguros)
Você tem a seguinte rota desenhada nos mapeamentos em Excel:
- **Gateway Endpoint**: `/insurance/v2/{product_key}/quotes`
- **Método**: `GET`
Onde o `{product_key}` é variável de negócio. Precisamos que o Kong valide que isso seja apenas métodos de leitura (GET) e não colida com outras apis base.

---

## 1. Declarando o serviço e rota no decK

Para o desenvolvedor atuar localmente acessando seu sistema em backend, criaremos um arquivo `deck.yaml` nesta pasta.
Nele instruiremos o uso de regex (expressão regular) no path do Gateway em notação de "expressions" onde o router do Kong reconhecerá o conteúdo dinâmico como uma variável nomeada, por ex: `(?<product_key>[^/]+)`.

> **⚠️ Atenção:** O `url` do serviço aponta para o `echo-server` local (`http://host.docker.internal:8080`). Isso nos permite observar claramente o que o Kong envia ao backend após processar a requisição.

Crie/Visualize o arquivo `03-roteamento.yaml` desta pasta:
```yaml
_format_version: "3.0"
services:
- name: insurance-api
  url: http://host.docker.internal:8080  # <- Desenvolvedores trocarão pela URL real na rede Pottencial
  routes:
  - name: get-quotes-with-key
    expression: (http.method == "GET") && (http.path ~ "^/insurance/v2/(?<product_key>[^/]+)/quotes$")
    preserve_host: false
    strip_path: false
```

---

## 2. Aplicando a configuração e Testando

Aplique a mudança efêmera da sua máquina local de forma síncrona com o seu Space na Nuvem:
```bash
deck gateway ping --konnect-token $KONNECT_TOKEN --konnect-addr $KONNECT_ADDR --konnect-control-plane-name "$CONTROL_PLANE_NAME"
deck gateway sync 03-roteamento.yaml --konnect-token $KONNECT_TOKEN --konnect-addr $KONNECT_ADDR --konnect-control-plane-name "$CONTROL_PLANE_NAME"
```

Valide:

```bash
curl -i http://localhost:8000/insurance/v2/auto/quotes
# O Kong deve aceitar, pois "auto" casa na regex como product_key

curl -i -X POST http://localhost:8000/insurance/v2/auto/quotes
# O Kong deve recusar "No route matched" pois o expression restringe via "(http.method == 'GET')"
```
