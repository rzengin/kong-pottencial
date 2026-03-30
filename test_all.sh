#!/bin/bash

# Define absolute output path
export LOG_FILE="$(pwd)/docs/Log_Testes_Cenarios.md"

echo "# 📜 Log de Validação dos Cenários (POC Kong Konnect)" > $LOG_FILE
echo "Data da Execução: $(date)" >> $LOG_FILE
echo "Control Plane: **$CONTROL_PLANE_NAME**" >> $LOG_FILE
echo "" >> $LOG_FILE

log() {
  echo "" >> $LOG_FILE
  echo "## $1" >> $LOG_FILE
  echo "⌛ Processando $1..."
}

run() {
  echo "\`\`\`bash" >> $LOG_FILE
  echo "$ $1" >> $LOG_FILE
  eval $1 >> $LOG_FILE 2>&1
  echo "\`\`\`" >> $LOG_FILE
  echo "" >> $LOG_FILE
}

sync() {
  echo "Sincronizando via decK ($1)..."
  echo "\`\`\`bash" >> $LOG_FILE
  echo "$ deck gateway sync $1 --konnect-token \$KONNECT_TOKEN --konnect-control-plane-name \"\$CONTROL_PLANE_NAME\"" >> $LOG_FILE
  deck gateway sync $1 --konnect-token $KONNECT_TOKEN --konnect-control-plane-name "$CONTROL_PLANE_NAME" >> $LOG_FILE 2>&1
  echo "\`\`\`" >> $LOG_FILE
  echo "Aguardando 12 segundos para a sincronização SaaS -> Edge Server refeltir..."
  sleep 12
}

# 01
log "Cenário 01: Limpeza Total do Ambiente"
echo "\`\`\`bash" >> $LOG_FILE
echo "$ deck gateway reset --force ..." >> $LOG_FILE
deck gateway reset --konnect-token $KONNECT_TOKEN --konnect-control-plane-name "$CONTROL_PLANE_NAME" --force >> $LOG_FILE 2>&1
echo "\`\`\`" >> $LOG_FILE

# 02
log "Cenário 02: Autenticação Zero-Atrito"
cd curso_practico/02-Autenticacao-Oauth2
./setup-keycloak.sh > /dev/null
sync "02-auth.yaml"
run "python3 cliente_sensedia_mock.py"
run "./lab-a-stateless.sh"
cd ../..

# 03
log "Cenário 03: Roteamento Avançado com Expressions"
cd curso_practico/03-Roteamento-Avanzado-com-Expressions
sync "03-roteamento.yaml"
run "curl -s -i http://localhost:8000/insurance/v2/auto/quotes"
cd ../..

# 04
log "Cenário 04: Reescrita de Rotas e Métodos"
cd curso_practico/04-Reescrita-de-Rotas-e-Metodos
sync "04-reescrita.yaml"
run "curl -s -i http://localhost:8000/insurance/v2/vida/quotes/9922"
cd ../..

# 05
log "Cenário 05: Substituindo Lua - Transformação de Headers"
cd curso_practico/05-Substituindo-Lua-Transformacao-Headers
sync "05-transformacao.yaml"
run "curl -s -i http://localhost:8000/insurance/v2/residencial/quotes"
cd ../..

# 06
log "Cenário 06: Substituindo Lua - TraceID e Observabilidade"
cd curso_practico/06-Substituindo-Lua-TraceID-e-OTLP
sync "06-trace.yaml"
run "curl -s -i http://localhost:8000/trace"
cd ../..

# 07
log "Cenário 07: Substituindo Lua - Autenticação M2M Nativa"
cd curso_practico/07-Substituindo-Lua-M2M-OIDC
sync "07-m2m-hefesto.yaml"
run "curl -s -i http://localhost:8000/m2m"
cd ../..

# 08
log "Cenário 08: Controle de Acesso por Consumidor (ACL)"
cd curso_practico/08-Controle-de-Acesso-Por-Consumidor-ACL
sync "08-acl.yaml"
log "Tentativa Desautorizada:"
run "curl -s -i http://localhost:8000/fechada"
log "Tentativa Autorizada (com API Key):"
run "curl -s -i http://localhost:8000/fechada -H 'apikey: minha-chave-secreta'"
cd ../..

# 09
log "Cenário 09: Segurança WAF (SQLi)"
cd curso_practico/09-Protecao-Web-WAF-SQLi-XSS
sync "09-waf.yaml"
log "Ataque SQL Injection Simulado:"
run "curl -s -i -X POST http://localhost:8000/waf -d 'user=1 OR 1=1' -d 'password=hacked'"
cd ../..

echo "🎉 Testes Finalizados! Log salvo em $LOG_FILE"
