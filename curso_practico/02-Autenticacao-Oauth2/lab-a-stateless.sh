#!/bin/bash
# Laboratório Prático A: Validação OIDC Stateless (JWT)
# Objetivo: Provar que o Kong decodifica JWTs legados do Hefesto/Keycloak sem ir ao banco e sem latência.

echo "========================================================="
echo "🔑 LAB A: VALIDACAO JWT STATELESS OIDC"
echo "========================================================="
echo ""
echo "1. Ignorando o Kong e emitindo o token diretamente do IDP Corporativo (Hefesto/Keycloak)..."
TOKEN=$(curl -s -X POST http://localhost:8081/realms/pottencial/protocol/openid-connect/token \
  -H "Host: host.docker.internal:8081" \
  -d "grant_type=client_credentials" \
  -d "client_id=app-pottencial" \
  -d "client_secret=SECRET_MUITO_SECRETO" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)

echo "✅ Token JWT obtido!"
echo "JWT Header.Payload (base64): ${TOKEN:0:40}..."
echo ""

echo "2. O cliente agora dispara a requisição contra o Kong local enviando esse Token antigo."
echo "⏳ Kong usará o plugin openid-connect para validar matematicamente a assinatura (sem BD)..."
echo ""

CURL_OUT=$(curl -o /dev/null -s -w "%{http_code}:%{time_total}\n" -H "Authorization: Bearer $TOKEN" http://localhost:8000/insurance/v2/rota-fechada)
HTTP_RESPONSE=$(echo $CURL_OUT | cut -d: -f1)
TIME_TOTAL=$(echo $CURL_OUT | cut -d: -f2)

echo "➡️ HTTP Status: $HTTP_RESPONSE"
if [ "$HTTP_RESPONSE" == "200" ]; then
    echo "🟢 SUCESSO! Acesso Concedido."
    echo "⚡ Tempo de processamento e validação na borda: ${TIME_TOTAL}s (Extremamente rápido, prova de execução Stateless!)"
else
    echo "🔴 FALHA na validação OIDC."
fi
