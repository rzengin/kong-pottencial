# Capítulo 05: Substituindo Lua - Transformação de Headers e Payload

Muitas vezes, a necessidade da Pottencial (vinda de legados como Sensedia) é garantir que o backend consuma dados injetados que nasceram dinamicamente do Path.
No exemplo do script `kong-importer-excel`, se o cliente enviasse `GET /insurance/v2/auto/quotes`, o backend precisará do `{product_key}` (neste caso "auto") dentro do Body como JSON, e/ou no Header como `x-product-key`.

O decK permite integrar de forma elegante o **Request Transformer Plugin** com as capturas nomeadas do router "expressions".

---

## 1. Mapeando Variaveis do Router no Request Transformer

Vamos incrementar nosso caso anterior incluindo o plugin associado à rota criada.

Crie ou visualize o arquivo `05-transformacao.yaml` desta pasta:
```yaml
_format_version: "3.0"
services:
- name: insurance-api
  url: http://host.docker.internal:8080
  routes:
  - name: get-quotes-with-key
    expression: (http.method == "GET") && (http.path ~ "^/insurance/v2/(?<product_key>[^/]+)/quotes$")
    preserve_host: false
    strip_path: false
    plugins:
    - name: request-transformer
      config:
        add:
          headers:
          - x-product-key:$(uri_captures.product_key)
          body:
          - product_key:$(uri_captures.product_key)
```

## 2. Aplicar e Validar

Substitua sua configuração existente executando o sync de `decK`:
```bash
deck gateway sync 05-transformacao.yaml --konnect-token $KONNECT_TOKEN --konnect-addr $KONNECT_ADDR --konnect-control-plane-name "$CONTROL_PLANE_NAME"
```

Valide:
```bash
curl -i http://localhost:8000/insurance/v2/residencial/quotes
```

O plugin interceptará a chamada antes de chegar ao seu backend real e fará um parse da string `residencial` substituindo no namespace interno da sintaxe de injeção `$(uri_captures.product_key)`. O seu servidor receberá, transparente, o cabecalho extra requerido por regras de negócio de retrocompatibilidade.
