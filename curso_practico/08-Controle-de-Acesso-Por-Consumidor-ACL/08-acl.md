# Capítulo 08: Controle de Acesso Por Consumidor (ACL Nativo)

No levantamento de dificuldades com a migração Sensedia, os engenheiros da Pottencial destacaram a restrição de que "*É possível restringir um consumidor a acessar apenas uma API específica*", questionando como fazer isso sem atributos complexos. 

O Kong resolve essa demanda (Impedimento #3 do PDF) não guardando propriedades pesadas nos Consumidores, mas utilizando as poderosas *Access Control Lists* (ACL).

O plugin **`acl`** vincula as credenciais de um consumidor a grupos lógicos permitidos ou bloqueados no Gateway.

## Solução Declarativa

Se você quiser permitir que apenas o consumidor OIDC (ou chave física) "Pottencial Seguros Interno" acesse `/insurance/v2/rota-fechada`, definimos:

```yaml
plugins:
- name: acl
  config:
    allow: 
      - "parceiros_homologados"
      - "admin_pottencial"

# E então amarra-se o Consumer àquela ACL especifica
consumers:
- username: App_Pottencial
  acls:
  - group: "parceiros_homologados"
```

A Edge Security barrará imediatamente qualquer token OIDC e consumidor rastreado que tentar passar por essa API (Status: 403 Forbidden) se eles não tiverem o grupo `parceiros_homologados` amarrado. Tudo feito de maneira stateless.

---

## 2. Aplicar, Validar e Concluir

Sincronize sua configuração executando isto na pasta do capítulo:
```bash
deck gateway sync 08-acl.yaml --konnect-token $KONNECT_TOKEN --konnect-addr $KONNECT_ADDR --konnect-control-plane-name "$CONTROL_PLANE_NAME"
```

Tente acessar a rota (como não temos token nesta chamada, ou se tivéssemos e não tivéssemos o ACL, o Kong rejeitará):
```bash
curl -i http://localhost:8000/fechada
```

**2. O Cenário de Sucesso (Permitido):**
Mas para provar que o acesso não está 100% quebrado, vamos fazer o Kong nos identificar usando o plugin `key-auth` que adicionamos e passar pela catraca do ACL, pois este consumidor foi atrelado ao grupo `parceiros_homologados`:
```bash
curl -i http://localhost:8000/fechada -H "apikey: minha-chave-secreta"
```

A resposta será `HTTP/1.1 200 OK`. Kong validou quem você era (Autenticação) e confirmou seus grupos de acesso autorizados (Autorização) em frações de milissegundo, sem invocar o Identity Provider toda vez!
