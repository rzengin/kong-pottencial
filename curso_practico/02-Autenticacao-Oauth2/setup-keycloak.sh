#!/bin/bash
set -e

KEYCLOAK_URL="http://localhost:8081"
ADMIN_USER="admin"
ADMIN_PASS="admin"
REALM_NAME="pottencial"
CLIENT_ID="app-pottencial"
CLIENT_SECRET="SECRET_MUITO_SECRETO"

echo "1. Obtendo token admin do Keycloak..."
TOKEN=$(curl -s -X POST "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=$ADMIN_USER" \
  -d "password=$ADMIN_PASS" \
  -d "grant_type=password" \
  -d "client_id=admin-cli" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "❌ Falha ao obter token admin"
  exit 1
fi

echo "2. Resetando e Criando Realm '$REALM_NAME' (Limpeza de estado anterior)..."
curl -s -X DELETE "$KEYCLOAK_URL/admin/realms/$REALM_NAME" \
  -H "Authorization: Bearer $TOKEN" > /dev/null

curl -s -X POST "$KEYCLOAK_URL/admin/realms" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "realm": "'$REALM_NAME'",
    "enabled": true
  }' > /dev/null

echo "3. Criando Client '$CLIENT_ID' com Client Credentials ativado..."
curl -s -X POST "$KEYCLOAK_URL/admin/realms/$REALM_NAME/clients" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "clientId": "'$CLIENT_ID'",
    "enabled": true,
    "serviceAccountsEnabled": true,
    "standardFlowEnabled": false,
    "directAccessGrantsEnabled": false,
    "clientAuthenticatorType": "client-secret",
    "secret": "'$CLIENT_SECRET'",
    "protocolMappers": [
      {
        "name": "Sensedia Access Flags",
        "protocol": "openid-connect",
        "protocolMapper": "oidc-hardcoded-claim-mapper",
        "config": {
          "claim.name": "sensedia-access-flags",
          "claim.value": "PREMIUM,VIP,MIGRATED",
          "jsonType.label": "String",
          "access.token.claim": "true",
          "id.token.claim": "true",
          "userinfo.token.claim": "false"
        }
      },
      {
        "name": "Sensedia Internal ID",
        "protocol": "openid-connect",
        "protocolMapper": "oidc-hardcoded-claim-mapper",
        "config": {
          "claim.name": "sensedia-internal-identifier",
          "claim.value": "APP-998877",
          "jsonType.label": "String",
          "access.token.claim": "true",
          "id.token.claim": "true",
          "userinfo.token.claim": "false"
        }
      }
    ]
  }' > /dev/null

echo "✅ Configuração do Keycloak finalizada com sucesso!"
echo ""
echo "Para obter um token OIDC via Client Credentials:"
echo "curl -X POST http://localhost:8081/realms/$REALM_NAME/protocol/openid-connect/token \\"
echo "  -d \"grant_type=client_credentials\" \\"
echo "  -d \"client_id=$CLIENT_ID\" \\"
echo "  -d \"client_secret=$CLIENT_SECRET\""
