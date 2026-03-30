# Capítulo 00: Setup do Ambiente

Bem-vindo ao curso prático de Kong Konnect! O seu **Control Plane** no Konnect e o seu **Data Plane** local já foram provisionados. Neste capítulo vamos:

1. Subir os serviços emuladores necessários para o curso.
2. Configurar as variáveis de ambiente do `decK`.
3. Validar que tudo está conectado e funcionando.

---

## 1. Subindo os Serviços Emuladores

Utilizamos três serviços simulados para demonstrar os cenários sem dependência de infraestrutura corporativa:

| Serviço | Imagem | Porta | Propósito |
|---------|--------|-------|-----------|
| **echo-server** | `ealen/echo-server` | `8080` | Reflete qualquer header/body recebido. Ideal para verificar transformações do Kong. |
| **auth-server** | `keycloak:24.0.1` | `8081` | Substitui o **Hefesto** (IDP corporativo). Emula OAuth2/OIDC Client Credentials localmente. |
| **api-mock** | `wiremock:3.5.4` | `8082` | Simula respostas das APIs de cotações e apólices sem conexão com sistemas internos. |

Na pasta deste capítulo (`00-Setup/`), execute:
```bash
docker compose up -d
```

Verifique que os três containers subiram com sucesso:
```bash
docker compose ps
```

### Validando o Echo Server
```bash
curl -i http://localhost:8080/ping
# Deve retornar 200 com um JSON mostrando os headers recebidos
```

### Validando o Auth Server (Keycloak)
Acesse [http://localhost:8081](http://localhost:8081) no browser.
Faça login com `admin / admin` e confirme que o Keycloak Admin Console carrega.

### Validando o WireMock
```bash
curl -i http://localhost:8082/__admin/
# Deve retornar 200 com a lista de stubs configurados (vazia inicialmente)
```

---

## 2. Configurando as Variáveis de Ambiente do decK

Defina as seguintes variáveis no seu terminal. Você as usará em **todos** os labs subsequentes:

```bash
export KONNECT_TOKEN="SEU_PAT_COPIADO"
export KONNECT_ADDR="https://us.api.konghq.com"
export CONTROL_PLANE_NAME="Local_Gateway_Seu_Nome"
export CONTROL_PLANE_ID="SEU_ID_DE_CP_COPIADO_DO_KONNECT"
```

> **💡 Dica:** Para não precisar exportar isso a cada sessão, adicione as linhas acima ao seu `~/.zshrc` ou `~/.bashrc`.

---

## 3. Validando a Conexão com o Konnect

```bash
deck gateway ping \
  --konnect-token $KONNECT_TOKEN \
  --konnect-addr $KONNECT_ADDR \
  --konnect-control-plane-name "$CONTROL_PLANE_NAME"
```

Resultado esperado:
```
Successfully Konnected to the PERCEPTIVA organization!
```

---

## 4. Validando o Data Plane Local

Faça uma chamada direta ao proxy do Kong na sua máquina (porto `8000`). Como ainda não há rotas configuradas, o resultado esperado é um erro 404 do Kong — o que confirma que o Data Plane está ativo e recebendo tráfego:

```bash
curl -i http://localhost:8000/qualquer-rota
# HTTP/1.1 404 Not Found
# {"message":"no Route matched with those values"}
```

---

> **Próximo Passo:** No Capítulo 01, aprenderemos a usar o `decK` para limpar qualquer configuração residual e garantir que começamos cada laboratório com um ambiente limpo.
