# Capítulo 06: Substituindo Lua - Trace ID e OTLP (Datadog)

De acordo com o mapeamento da migração Sensedia, a equipe da Pottencial desenvolveu um plugin Lua customizado chamado `trace-id` com a finalidade exclusiva de copiar o cabeçalho gerado pelo Kong (`x-kong-requestid`) para uma variável nomeada `x-trace-id`, e integrá-la às ferramentas de OTLP.

No entanto, no Kong Konnect SaaS/Enterprise, **a escrita e manutenção de código Lua injetado via Docker Volumes é um extremo antipadrão de engenharia** que cria barreiras de atualização.

## 1. A Solução Nativa (Zero Code)

Neste laboratório, mostraremos como superar simultaneamente duas barreiras da Pottencial usando arquitetura declarativa:
1. Replicar a gestão do Trace-ID.
2. Endereçar o Ponto 5 das dificuldades: Integração OpenTelemetry & Datadog.

Observe a configuração elegante `06-trace.yaml`:

```yaml
plugins:
- name: correlation-id
  config:
    header_name: x-trace-id  # O nome exigido pelo backend da Pottencial
    generator: uuid
    echo_downstream: true    # Retorna o ID pro app mobile
- name: opentelemetry
  config:
    endpoint: "http://datadog-agent:4318/v1/traces" # Porta HTTP Datadog Agent OTLP
```

> **⚠️ Simulação Elegante com Jaeger:** O endpoint `host.docker.internal:4318` é o porto oficial de Telemetria (OTLP). Na Pottencial aponta real para o `datadog-agent`. Mas para esta demonstração corporativa, seu infra providenciou o **Jaeger** local. Vá na porta [http://localhost:16686](http://localhost:16686) e divirta-se renderizando as métricas gráficas (Flame-Graphs) dos rastreios milissegundo a milissegundo do Kong!

Com apenas estas propriedades no decK, a camada de Gateways gerará os UUIDs com a exata nomenclatura `x-trace-id`, despachando automaticamente os logs de Span OTLP formatados para o Datadog Agent (ou simulador interno), provando a superioridade do modelo declarativo corporativo sobre customizações complexas!

---

## 2. Aplicar, Validar e Concluir

Sincronize sua configuração executando o comando abaixo na pasta deste capítulo:
```bash
deck gateway sync 06-trace.yaml --konnect-token $KONNECT_TOKEN --konnect-addr $KONNECT_ADDR --konnect-control-plane-name "$CONTROL_PLANE_NAME"
```

Valide a chamada fazendo um curl (aguarde 3 segundos após o sync para a consistência eventual fletir para o Docker local):
```bash
curl -i http://localhost:8000/trace
```

* **Passo Final:** Abra a interface do Jaeger em `http://localhost:16686`, selecione o serviço `kong-gateway` e comprove maravilhado a visualização dos traces sem ter escrito una única linha de código (`.lua`).
