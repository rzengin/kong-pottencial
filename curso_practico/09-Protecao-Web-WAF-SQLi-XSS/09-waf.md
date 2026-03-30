# Capítulo 09: Proteção Web Global - WAF, SQLi e XSS

A Dificuldade/Impedimento final relatada pela Pottencial (#4) é imperativa na migração de Sensedia para Kong Konnect:
*"Todos os serviços possuem interceptores de proteção contra SQL Injection e XSS Injection aplicados globalmente"*.

Em Kong Enterprise (Konnect), não programamos filtros Lua manualmente para varrer Injections (WAFs manuais são caros, lerdos e imprecisos).

Kong propõe duas vias arquiteturais robustas:

## Via 1: The AppSec Plugin (Kong WAF Avançado)
O Konnect possui o módulo *Kong AppSec* nativo capaz de bloquear assinaturas CVE, malwares e ataques OWASP Top 10 sem regras confusas.

## Via 2: O Request-Validator (Abordagem API Gateway Limpa)
O plugin `request-validator` garante, através do *OpenAPI Schema Specification*, que todas as requisições (`Body` e `Params`) batem exatamente com as definições de Tipos (`Integer`, `String max_size 50`, `Enum`). Se um payload envia `<script>alert('XSS')</script>`, ele falha a validação de tipo de entrada estrita, bloqueando XSS e SQLi instantaneamente através de padronização restrita.

```yaml
plugins:
- name: request-validator
  config:
    version: draft4
    body_schema: "{\"type\": \"object\", \"properties\": {\"id\": {\"type\": \"integer\"}}, \"required\": [\"id\"]}"
    allowed_content_types:
      - "application/json"
```

Implementar estes plugins garante a paridade final e a segurança integral (SecOps) exigida pela arquitetura legada Sensedia de maneira moderna e auditável.

---

## 2. Aplicar, Validar e Concluir

Sincronize o deck com WAF/Validador:
```bash
deck gateway sync 09-waf.yaml --konnect-token $KONNECT_TOKEN --konnect-addr $KONNECT_ADDR --konnect-control-plane-name "$CONTROL_PLANE_NAME"
```

Tente enviar um payload malicioso ou mal formatado:
```bash
curl -i -X POST http://localhost:8000/waf \
  -H "Content-Type: application/json" \
  -d '{"id": "texto_malicioso_inves_de_int"}'
```

O Kong barrará o request instantaneamente (400 Bad Request) porque definimos estritamente qual schema OpenApi é válido!
