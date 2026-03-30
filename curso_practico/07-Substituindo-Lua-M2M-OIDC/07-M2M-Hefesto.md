# Capítulo 07: Substituindo Lua - M2M (Machine-to-Machine) Hefesto OIDC

O terceiro e mais crítico plugin Lua escrito manual ("*oauth-client-credentials*") buscava na rede da Pottencial (via `POST /connect/token`) uma credencial para permitir que o Gateway conversasse de forma autenticada com o serviço internal protegido pelo *Hefesto*. Novamente, delegar o cacheamento de Tokens (TTL 55 mins) para scripts caseiros em plataformas Enterprise é expor a operação a riscos pesados de queda do microserviço e latência.

Felizmente, a funcionalidade "Gateway atuando como Relying Party M2M para o Upstream" não exige programação paralela. Kong fornece **OIDC Application Registration**, *Upstream Oauth*, ou **Serverless Pre-Functions** em Javascript e WebAssembly altamente paralelizados para orquestrações customizadas. 

O padrão oficial para evitar código macarrônico nestes casos críticos da migração de Sensedia com Hefesto no Konnect é integrar a política M2M (Kong gerando e anexando o Client Credentials no Edge):

```yaml
plugins:
- name: openid-connect
  config:
    client_id: ["kong-apigateway-server"]
    client_secret: ["SUA_CHAVE_KONG"]
    issuer: "http://hefesto.pottencial.com.br/connect"
```

---

## 2. Aplicar, Validar e Concluir

Sincronize sua configuração executando o comando abaixo na pasta deste capítulo:
```bash
deck gateway sync 07-m2m-hefesto.yaml --konnect-token $KONNECT_TOKEN --konnect-addr $KONNECT_ADDR --konnect-control-plane-name "$CONTROL_PLANE_NAME"
```

Valide a chamada fazendo um curl:
```bash
curl -i http://localhost:8000/m2m
```
