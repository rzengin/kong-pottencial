# Capítulo 01: Limpeza e Preparação (Reset com decK)

Em qualquer pipeline de desenvolvimento, antes de aplicar rotas ou plugins experimentais, muitas vezes é necessário garantir que seu Data Plane comece com as configurações exatamente do zero, sem lixo residual de testes antigos.

Na prática das operações diárias, você fará push de um novo estado validado para evitar conflitos de rotas.
Aqui vamos conhecer o comando "reset" do `decK`, a principal ferramenta CLI (Command Line Interface) do ecossistema Kong.

---

## 1. Resetando as configurações do ambiente dev

Nós vamos garantir a limpeza total das rotas do seu "Local_Gateway" utilizando seu PAT (Personal Access Token).

No seu terminal, rode o seguinte comando destrutivo:
```bash
# Aviso: Este comando apagará TODOS OS SERVIÇOS, ROTAS E PLUGINS
# associados ao Control Plane 'Local_Gateway_Seu_Nome' (ambiente isolado do dev).

deck gateway reset --konnect-token $KONNECT_TOKEN --konnect-addr $KONNECT_ADDR --konnect-control-plane-name "$CONTROL_PLANE_NAME" --force
```

A console exibirá todos os deltas como `delete`. Isso confirma que o espaço está limpo e disponível para os laboratórios práticos.

---

## 2. Visão do decK File (Estado Declarativo)

Agora aprenderemos como o `decK` gerencia o provisionamento da nossa API sem que tenhamos que usar a UI.
O decK trabalha com arquivos `kong.yaml` (ou `.yml`).

Ele provê três vantagens fundamentais no seu ciclo de vida de desenvolvimento de APIs:
1. **Infraestrutura como Código (IaC)**: Configurações são salvas no Git.
2. **Sync**: Detecta as métricas de descompasso (`diff`) do que está na nuvem Konnect vs que você escreveu no arquivo.
3. **Escalaridade Local**: Elimina a necessidade de acesso produtivo; os desenvolvedores definem o estado desejado, validam localmente com seus backends de testes e realizam commits.

Nos próximos laboratórios, simularemos a criação dinâmica de rotas vindas do script Node (`kong-importer-excel`) que precisam de mapeamentos flexíveis para o serviço legado da Pottencial utilizando puramente a IaC.
