#!/usr/bin/env python3
import urllib.request
import urllib.parse
import json
import ssl

def print_separator(title):
    print(f"\n{'='*60}")
    print(f" {title} ")
    print(f"{'='*60}")

def main():
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE

    print_separator("1. EMULANDO APLICAÇÃO SENSEDIA LEGADA (Solicitação de Token)")
    
    # 1. Solicita o Token pelo endpoint legado do Gateway (Sensedia proxy)
    token_url = "http://localhost:8000/oauth/v3/access-token"
    
    payload = urllib.parse.urlencode({
        'grant_type': 'client_credentials',
        'client_id': 'app-pottencial',
        'client_secret': 'SECRET_MUITO_SECRETO'
    }).encode('utf-8')

    headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Host': 'host.docker.internal:8081'  # Necessário para assinar via Docker Mac network OIDC
    }

    req = urllib.request.Request(token_url, data=payload, headers=headers, method='POST')
    
    print(f"➡️  CHAMADA MOCK (Gateway Kong escondendo o Keycloak):")
    print(f"POST {token_url}")
    print(f"Headers do Cliente: {json.dumps(headers, indent=2)}")
    print(f"Payload (Body): {payload.decode('utf-8')}")
    
    try:
        with urllib.request.urlopen(req, context=ctx) as response:
            res_body = response.read()
            token_data = json.loads(res_body)
            access_token = token_data.get('access_token')
            print(f"\n✅ RESPOSTA DO GATEWAY (Status {response.status}):")
            print(f"Token JWT Recebido (Trunked): {access_token[:30]}...[REDACTED]...{access_token[-20:]}")
    except urllib.error.URLError as e:
        print(f"❌ Erro na requisição: {e}")
        if hasattr(e, 'read'):
            print(e.read().decode())
        return

    print_separator("2. CONSUMINDO A API FINANCEIRA MIGRADA (Kong OIDC + Props Sensedia)")

    api_url = "http://localhost:8000/insurance/v2/rota-fechada"
    
    api_headers = {
        'Authorization': f'Bearer {access_token}',
        'Accept': 'application/json'
    }

    print(f"➡️  CHAMADA DA APLICAÇÃO (Para API de Negócio):")
    print(f"GET {api_url}")
    print(f"Enviando Headers:")
    print(f"  Authorization: Bearer {access_token[:15]}...")

    req_api = urllib.request.Request(api_url, headers=api_headers, method='GET')

    try:
        with urllib.request.urlopen(req_api, context=ctx) as response:
            print(f"\n✅ SUCESSO! Acesso liberado (Status {response.status})")
            
            res_body = response.read()
            backend_data = json.loads(res_body)
            
            print(f"\n--- VISÃO DO DESENVOLVEDOR BACKEND (O que o Echo-Server recebeu!) ---")
            
            # Printando headers injetados nativamente
            backend_request = backend_data.get('request', {})
            backend_headers = backend_request.get('headers', {})
            kong_injected_headers = {
                "x-sensedia-flags": backend_headers.get("x-sensedia-flags", "NÃO ENCONTRADO"),
                "x-sensedia-id": backend_headers.get("x-sensedia-id", "NÃO ENCONTRADO"),
                "x-consumer-custom-id": backend_headers.get("x-consumer-custom-id", "NÃO ENCONTRADO"),
                "x-consumer-username": backend_headers.get("x-consumer-username", "NÃO ENCONTRADO")
            }
            
            print("O Kong interceptou a chamada na borda, validou o token e INJETOU AS SEGUINTES PROPRIEDADES LEGADAS (Migração Stateless):")
            print(json.dumps(kong_injected_headers, indent=4, ensure_ascii=False))

    except urllib.error.URLError as e:
        print(f"❌ Erro ao consumir API de negócio: {e}")
        if hasattr(e, 'read'):
            print(e.read().decode())

if __name__ == "__main__":
    main()
