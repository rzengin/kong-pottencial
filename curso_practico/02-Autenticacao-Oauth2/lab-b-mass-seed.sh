#!/bin/bash
# Laboratório Prático B: Importação em Massa de Tokens Opacos (Seed Sensedia)
# Objetivo: Demonstrar o conceito de Admin API para injetar tokens preexistentes da Sensedia no Kong.

echo "========================================================="
echo "🌱 LAB B: MASS SEED (MIGRAÇÃO DE TOKENS OPACOS)"
echo "========================================================="
echo ""
echo "📥 [MOCK] Conectando ao Banco de Dados Legado da Sensedia..."
sleep 1
echo "Extraindo tokens opacos das APIs de Parceiros legadas..."

# Variáveis Simuladas
CONSUMER_ID="app-pottencial"
LEGACY_TOKEN="SENSEDIA_HASH_${RANDOM}_ABC123OPAQUE"
TTL="86400"

echo ""
echo "🔍 Token obsoleto Encontrado:"
echo " > Consumer: $CONSUMER_ID"
echo " > Hash Opaco: $LEGACY_TOKEN"
echo " > Tempo de Vida (TTL): $TTL Segundos"
echo ""

echo "⚡ [KONG ADMIN API] Iniciando Semeio (Seed) para Nova Infraestrutura OAuth2 corporativa..."
sleep 1

# O Comando de Injeção Kong
echo "Executing: curl -X POST http://localhost:8001/consumers/$CONSUMER_ID/oauth2 ..."

HTTP_RESPONSE=$(curl -o /dev/null -s -w "%{http_code}\n" -X POST http://localhost:8001/consumers/$CONSUMER_ID/oauth2 \
  -d "name=Sensedia Legacy Token $RANDOM" \
  -d "access_token=$LEGACY_TOKEN" \
  -d "expires_in=$TTL")

echo "========================================================="
if [ "$HTTP_RESPONSE" == "201" ]; then
    echo "✅ [SUCESSO HTTP 201] Token Injetado Nativamente no Kong Gateway!"
    echo "O consumidor não notará nada! O cliente pode despachar sua request agora mesmo usando:"
    echo "Authorization: Bearer $LEGACY_TOKEN"
elif [ "$HTTP_RESPONSE" == "404" ]; then
    echo "⚠️  Falha! Verifique se seu Data Plane Admin localhost:8001 está ativo."
else
    echo "🔄 Aviso: A requisição retornou $HTTP_RESPONSE. (Certifique-se de que a API Kong Admin está exposta e com plugin OAuth2 habilitado caso queira validacao hard)."
fi
echo "========================================================="
