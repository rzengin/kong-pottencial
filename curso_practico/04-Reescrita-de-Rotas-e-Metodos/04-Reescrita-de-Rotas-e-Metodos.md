# Capítulo 04: Reescrita de Rotas e Métodos (HTTP Method Override)

Um padrão arquitetural muito comum na Pottencial é que a chamada REST gerada pelo App mobile ou Site não tenha o mesmo path do que o microserviço de backend espera (`URI mismatch`). 

Um exemplo tirado da migração:
O gateway pode receber via GET a URI: `/insurance/v2/{product_key}/quotes/{quote_id}`.
Mas a arquitetura de backend do legado requer:
- Caminho (Path): `/quotes/v2/quotes/:quoteId`
- Método HTTP: `POST`

---

## 1. Usando replace.uri no Request Transformer

O Kong possui um campo interno na configuração do transformer com a propriedade `replace` para URI e também altera-se o verbo HTTP dinamicamente de acordo com match.

Explore o arquivo `04-reescrita.yaml` desta pasta:
```yaml
_format_version: "3.0"
services:
- name: insurance-api
  url: http://host.docker.internal:8080
  routes:
  - name: override-methods-key
    expression: (http.method == "GET") && (http.path ~ "^/insurance/v2/(?<product_key>[^/]+)/quotes/(?<quote_id>[^/]+)$")
    plugins:
    - name: request-transformer
      config:
        http_method: POST
        replace:
          uri: /quotes/v2/quotes/$(uri_captures.quote_id)
        add:
          headers:
          - x-product-key:$(uri_captures.product_key)
```

Observe que nós injetamos o `product_key` capturado como Header. Paralelamente, usando o `.replace.uri`, nós cortamos o fragmento `insurance/v2/` da URL antes dessa ser mandada adiante para o mock ou serviço da intranet, traduzimos ela em `quotes/v2`, e embutimos a variável nativa `quote_id`. Além disso, a chamada REST que o kong recebeu em `GET` foi reescrita (`http_method: POST`).

---

## 2. Aplicar, Validar e Concluir

```bash
deck gateway sync 04-reescrita.yaml --konnect-token $KONNECT_TOKEN --konnect-addr $KONNECT_ADDR --konnect-control-plane-name "$CONTROL_PLANE_NAME"
```

Valide:
```bash
curl -i http://localhost:8000/insurance/v2/vida/quotes/99321
```

O gateway irá processar a chamada GET na porta 8000 da sua workstation e repassá-la ao seu Data Plane que reportará logs de roteamento transformado `POST /quotes/v2/quotes/99321` para o Upstream com seu `x-product-key: vida`.

**Parabéns!** O seu curso local da arquitetura de migração está completado. Use esse laboratório como base para sua experimentação rotineira com o Control Plane Konnect.
