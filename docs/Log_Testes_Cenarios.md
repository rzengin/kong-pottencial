# 📜 Log de Validação dos Cenários (POC Kong Konnect)
Data da Execução: Mon Mar 30 00:29:13 -03 2026
Control Plane: **Local Gateway**


## Cenário 01: Limpeza Total do Ambiente
```bash
$ deck gateway reset --force ...
deleting plugin request-validator for route waf-route
deleting route waf-route
deleting service insurance-api
Summary:
  Created: 0
  Updated: 0
  Deleted: 3
```

## Cenário 02: Autenticação Zero-Atrito
```bash
$ deck gateway sync 02-auth.yaml --konnect-token $KONNECT_TOKEN --konnect-control-plane-name "$CONTROL_PLANE_NAME"
creating consumer App_Pottencial
creating service keycloak-token-service
creating service insurance-api
creating route secure-api-route
creating route sensedia-token-proxy
creating plugin openid-connect for route secure-api-route
Summary:
  Created: 6
  Updated: 0
  Deleted: 0
```
```bash
$ python3 cliente_sensedia_mock.py

============================================================
 1. EMULANDO APLICAÇÃO SENSEDIA LEGADA (Solicitação de Token) 
============================================================
➡️  CHAMADA MOCK (Gateway Kong escondendo o Keycloak):
POST http://localhost:8000/oauth/v3/access-token
Headers do Cliente: {
  "Content-Type": "application/x-www-form-urlencoded",
  "Host": "host.docker.internal:8081"
}
Payload (Body): grant_type=client_credentials&client_id=app-pottencial&client_secret=SECRET_MUITO_SECRETO
❌ Erro na requisição: HTTP Error 404: Not Found
{
  "message":"no Route matched with those values",
  "request_id":"6a13f342c1566c194614ad2ec255121f"
}
```

```bash
$ ./lab-a-stateless.sh
=========================================================
🔑 LAB A: VALIDACAO JWT STATELESS OIDC
=========================================================

1. Ignorando o Kong e emitindo o token diretamente do IDP Corporativo (Hefesto/Keycloak)...
✅ Token JWT obtido!
JWT Header.Payload (base64): eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwi...

2. O cliente agora dispara a requisição contra o Kong local enviando esse Token antigo.
⏳ Kong usará o plugin openid-connect para validar matematicamente a assinatura (sem BD)...

➡️ HTTP Status: 404
🔴 FALHA na validação OIDC.
```


## Cenário 03: Roteamento Avançado com Expressions
```bash
$ deck gateway sync 03-roteamento.yaml --konnect-token $KONNECT_TOKEN --konnect-control-plane-name "$CONTROL_PLANE_NAME"
creating route get-quotes-with-key
deleting plugin openid-connect for route secure-api-route
deleting route sensedia-token-proxy
deleting route secure-api-route
deleting service keycloak-token-service
deleting consumer App_Pottencial
Summary:
  Created: 1
  Updated: 0
  Deleted: 5
```
```bash
$ curl -s -i http://localhost:8000/insurance/v2/auto/quotes
HTTP/1.1 401 Unauthorized
Date: Mon, 30 Mar 2026 03:29:50 GMT
Content-Type: application/json; charset=utf-8
Connection: keep-alive
WWW-Authenticate: Bearer realm="host.docker.internal", error="invalid_token"
Content-Length: 26
X-Kong-Response-Latency: 4
Server: kong/3.13.0.0-enterprise-edition
X-Kong-Request-Id: 117bbe3dad9d1429e7e1e708f3168276

{"message":"Unauthorized"}```


## Cenário 04: Reescrita de Rotas e Métodos
```bash
$ deck gateway sync 04-reescrita.yaml --konnect-token $KONNECT_TOKEN --konnect-control-plane-name "$CONTROL_PLANE_NAME"
creating route override-methods-key
creating plugin request-transformer for route override-methods-key
deleting route get-quotes-with-key
Summary:
  Created: 2
  Updated: 0
  Deleted: 1
```
```bash
$ curl -s -i http://localhost:8000/insurance/v2/vida/quotes/9922
HTTP/1.1 404 Not Found
Date: Mon, 30 Mar 2026 03:30:05 GMT
Content-Type: application/json; charset=utf-8
Connection: keep-alive
Content-Length: 103
X-Kong-Response-Latency: 0
Server: kong/3.13.0.0-enterprise-edition
X-Kong-Request-Id: e1f8c5598090a10c3ec0067881096a5d

{
  "message":"no Route matched with those values",
  "request_id":"e1f8c5598090a10c3ec0067881096a5d"
}```


## Cenário 05: Substituindo Lua - Transformação de Headers
```bash
$ deck gateway sync 05-transformacao.yaml --konnect-token $KONNECT_TOKEN --konnect-control-plane-name "$CONTROL_PLANE_NAME"
creating route get-quotes-with-key
creating plugin request-transformer for route get-quotes-with-key
deleting plugin request-transformer for route override-methods-key
deleting route override-methods-key
Summary:
  Created: 2
  Updated: 0
  Deleted: 2
```
```bash
$ curl -s -i http://localhost:8000/insurance/v2/residencial/quotes
HTTP/1.1 404 Not Found
Date: Mon, 30 Mar 2026 03:30:21 GMT
Content-Type: application/json; charset=utf-8
Connection: keep-alive
Content-Length: 103
X-Kong-Response-Latency: 0
Server: kong/3.13.0.0-enterprise-edition
X-Kong-Request-Id: cbff0c2b1956b823a346bc2d51d0a244

{
  "message":"no Route matched with those values",
  "request_id":"cbff0c2b1956b823a346bc2d51d0a244"
}```


## Cenário 06: Substituindo Lua - TraceID e Observabilidade
```bash
$ deck gateway sync 06-trace.yaml --konnect-token $KONNECT_TOKEN --konnect-control-plane-name "$CONTROL_PLANE_NAME"
creating route trace-route
creating plugin correlation-id for route trace-route
creating plugin opentelemetry for route trace-route
deleting plugin request-transformer for route get-quotes-with-key
deleting route get-quotes-with-key
Summary:
  Created: 3
  Updated: 0
  Deleted: 2
```
```bash
$ curl -s -i http://localhost:8000/trace
HTTP/1.1 404 Not Found
Date: Mon, 30 Mar 2026 03:30:37 GMT
Content-Type: application/json; charset=utf-8
Connection: keep-alive
Content-Length: 103
X-Kong-Response-Latency: 1
Server: kong/3.13.0.0-enterprise-edition
X-Kong-Request-Id: 134d0a16431afc26396e400322f87914

{
  "message":"no Route matched with those values",
  "request_id":"134d0a16431afc26396e400322f87914"
}```


## Cenário 07: Substituindo Lua - Autenticação M2M Nativa
```bash
$ deck gateway sync 07-m2m-hefesto.yaml --konnect-token $KONNECT_TOKEN --konnect-control-plane-name "$CONTROL_PLANE_NAME"
creating route m2m-route
creating plugin openid-connect for route m2m-route
deleting plugin opentelemetry for route trace-route
deleting plugin correlation-id for route trace-route
deleting route trace-route
Summary:
  Created: 2
  Updated: 0
  Deleted: 3
```
```bash
$ curl -s -i http://localhost:8000/m2m
HTTP/1.1 302 Moved Temporarily
Date: Mon, 30 Mar 2026 03:30:53 GMT
Connection: keep-alive
Cache-Control: no-store
Set-Cookie: authorization=AQAAJ3tRj4KwBWp9Q1Ff2sOObJSL-5n1J8J-X9dNjPPs-Ddt7slpAAAAAAAAAQAfUavphpeTd3jAsQRtswD0AAAAE1ihN33qYxN5QPLPkmQglAfnG8rpM5YEocJ8QGRz1b1b9HqQ5pW8Ys5XTJe5_N7C_XC4DgQrWhOLXtb0CcD5ehjQ4hsYHrrqPtXlnTqbkU7S8ASEjiYd7BbNED66ALGxSHNn1kZQswQ_gmbQkUf0OK7FHMY-QIV4gysOixiU4LZVzvg5q4ZqrF2kyJ4NYvn1znLzBj96zP32Bwxs9tAR3wfst8oVMJWMsojRJpcVfA6T-AExw_u0tX7fN90FW3U9kITLhBrlt6aIsVGvG79yTw; Path=/; SameSite=Default; HttpOnly
Location: http://host.docker.internal:8081/realms/pottencial/protocol/openid-connect/auth?client_id=kong-apigateway-server&response_mode=query&scope=openid&code_challenge_method=S256&code_challenge=-7S_Z2fHNJq1R5Gn2xvfXTCo7_7965HrJC6i0FqfmQE&state=o1iinB-nusmaJYAEfXS_0MoZ&response_type=code&nonce=-8FKaL7lJUGeiYi-ozumN2FW&redirect_uri=http%3A%2F%2Flocalhost%3A8000%2Fm2m
Content-Length: 0
X-Kong-Response-Latency: 20
Server: kong/3.13.0.0-enterprise-edition
X-Kong-Request-Id: 5198814359d42a0b0539e04613315a07

```


## Cenário 08: Controle de Acesso por Consumidor (ACL)
```bash
$ deck gateway sync 08-acl.yaml --konnect-token $KONNECT_TOKEN --konnect-control-plane-name "$CONTROL_PLANE_NAME"
creating consumer App_Pottencial
creating key-auth creta for consumer App_Pottencial
creating acl-group parceiros_homologados for consumer App_Pottencial
creating route fechada-route
creating plugin acl for route fechada-route
creating plugin key-auth for route fechada-route
deleting plugin openid-connect for route m2m-route
deleting route m2m-route
Summary:
  Created: 6
  Updated: 0
  Deleted: 2
```

## Tentativa Desautorizada:
```bash
$ curl -s -i http://localhost:8000/fechada
HTTP/1.1 401 Unauthorized
Date: Mon, 30 Mar 2026 03:31:11 GMT
Content-Type: application/json; charset=utf-8
Connection: keep-alive
WWW-Authenticate: Key
Content-Length: 96
X-Kong-Response-Latency: 2
Server: kong/3.13.0.0-enterprise-edition
X-Kong-Request-Id: 710991493d58c80759d10635c933a14a

{
  "message":"No API key found in request",
  "request_id":"710991493d58c80759d10635c933a14a"
}```


## Tentativa Autorizada (com API Key):
```bash
$ curl -s -i http://localhost:8000/fechada -H 'apikey: minha-chave-secreta'
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
Content-Length: 1061
Connection: keep-alive
ETag: W/"425-sXSWSIWILR6c9lQi3UKOVOtnH7o"
Date: Mon, 30 Mar 2026 03:31:11 GMT
Server: kong/3.13.0.0-enterprise-edition
X-Kong-Upstream-Latency: 5
X-Kong-Proxy-Latency: 4
Via: 1.1 kong/3.13.0.0-enterprise-edition
X-Kong-Request-Id: 16cb6777ea92470569ea47197c62d13c

{"host":{"hostname":"host.docker.internal","ip":"::ffff:192.168.65.1","ips":[]},"http":{"method":"GET","baseUrl":"","originalUrl":"/","protocol":"http"},"request":{"params":{"0":"/"},"query":{},"cookies":{},"body":{},"headers":{"via":"1.1 kong/3.13.0.0-enterprise-edition","host":"host.docker.internal:8080","connection":"keep-alive","x-forwarded-for":"192.168.65.1","x-forwarded-proto":"http","x-forwarded-host":"localhost","x-forwarded-port":"8000","x-forwarded-path":"/fechada","x-forwarded-prefix":"/fechada","x-real-ip":"192.168.65.1","x-kong-request-id":"16cb6777ea92470569ea47197c62d13c","user-agent":"curl/8.7.1","accept":"*/*","apikey":"minha-chave-secreta","x-consumer-id":"94c32d94-009f-4833-bd10-9932f6b74e89","x-consumer-username":"App_Pottencial","x-credential-identifier":"5a3596b5-da2a-486f-bf16-a9fdc9f2b897","x-consumer-groups":"parceiros_homologados"}},"environment":{"PATH":"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin","HOSTNAME":"a31a6bf05ee6","PORT":"80","NODE_VERSION":"20.11.0","YARN_VERSION":"1.22.19","HOME":"/root"}}```


## Cenário 09: Segurança WAF (SQLi)
```bash
$ deck gateway sync 09-waf.yaml --konnect-token $KONNECT_TOKEN --konnect-control-plane-name "$CONTROL_PLANE_NAME"
creating route waf-route
creating plugin request-validator for route waf-route
deleting plugin acl for route fechada-route
deleting plugin key-auth for route fechada-route
deleting route fechada-route
deleting key-auth creta for consumer App_Pottencial
deleting acl-group parceiros_homologados for consumer App_Pottencial
deleting consumer App_Pottencial
Summary:
  Created: 2
  Updated: 0
  Deleted: 6
```

## Ataque SQL Injection Simulado:
```bash
$ curl -s -i -X POST http://localhost:8000/waf -d 'user=1 OR 1=1' -d 'password=hacked'
HTTP/1.1 400 Bad Request
Date: Mon, 30 Mar 2026 03:31:28 GMT
Content-Type: application/json; charset=utf-8
Connection: keep-alive
Content-Length: 52
X-Kong-Response-Latency: 2
Server: kong/3.13.0.0-enterprise-edition
X-Kong-Request-Id: 9cac6e72e49b900d3dfb814fc73bd839

{"message":"request body doesn't conform to schema"}```

