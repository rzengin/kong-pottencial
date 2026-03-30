# Política de Privacidade e Proteção de Dados
**Empresa:** Perceptiva
**Data da Última Revisão:** Outubro/2025
**Versão:** 1.0

## 1. Objetivo e Escopo

A presente **Política de Privacidade e Proteção de Dados** estabelece as diretrizes adotadas pela **Perceptiva** em conformidade com a **Lei Geral de Proteção de Dados Pessoais (LGPD - Lei nº 13.709/2018)**. 

O escopo desta Política contempla:
1. Os dados pessoais dos agentes internos (funcionários) e parceiros de negócio (B2B) da Perceptiva.
2. A formalização e declaração legal sobre a natureza operacional da nossa **Infraestrutura de Gerenciamento de APIs (API Gateway)** ofertada a nossos clientes constituintes.

## 2. Declaração de Tratamento de Dados Pessoais em Projetos (API Gateway)

No contexto dos serviços prestados a parceiros corporativos (como a Pottencial Seguradora), a Perceptiva atua estritamente na provisão de **infraestrutura de rede e conectividade ("Pass-Through")**.

Pela arquitetura intrínseca de operação do sistema, declaramos formalmente que **A Perceptiva NÃO realiza o armazenamento, coleta, modificação, combinação ou processamento secundário dos dados pessoais ou sensíveis dos clientes-finais dos nossos parceiros**.

Os mecanismos limitam-se ao monitoramento técnico anonimizado (telemetria, metadados criptografados e cabeçalhos operacionais) para o efetivo roteamento da requisição sistêmica. Assim:
*   Os preceitos de privacidade desde o desenvolvimento (**Privacy by Design** e **Privacy by Default**) asseguram que inexista retenção de payload.
*   **Minimização de Dados:** Limitamo-nos aos dados operacionais de infraestrutura que não enquadram-se na taxonomia de Dados Pessoais de terceiros.

## 3. Direitos dos Titulares de Dados

Apesar de a Perceptiva não deter papel de **Controlador** nem de **Operador em repouso** no cenário dos dados sensíveis trafegados na plataforma do cliente final, garantimos aderência operacional aos direitos do titular elencados na LGPD (Art. 18):

1.  **Redirecionamento:** Qualquer requisição recebida nos canais de atendimento da Perceptiva vinda de um titular buscando detalhes de processamento que refira-se ao ecossistema do cliente (sendo ele o Controlador) será sumariamente informada ao titular e redirecionada ao DPO/Responsável pelo Controlador num prazo inferior a D+2 úteis para devido trâmite e resposta final.
2.  **Transparência:** A Perceptiva informará o usuário que, tecnicamente, não possui custódia persistente para "Correção", "Anonimização" ou "Portabilidade" que advenham da massa do Controlador.

## 4. Avaliação de Impacto e Inventário (DPIA / Data Mapping)

### Inventário Mapeado:
Manteremos atualizado nosso *Registro de Operações de Tratamento* relativo essencialmente às bases legais para os colaboradores (para viés contratual RH) e parceiros de negócio. 

Para a **Infraestrutura de Plataforma do Cliente:** O mapa técnico consolida-se através de arquitetura de rede o fato que não transitam fluxos subjacentes salvos, extinguindo o risco por obsolescência e ausência de retenção. 

### DPIA - Relatório de Impacto à Proteção de Dados:
Sempre que uma mudança estrutural de software ou a instauração de arquitetura exigir trânsito de novas modalidades passíveis de captura sistêmica nos logs, o Comitê de Segurança elaborará obrigatoriamente um **DPIA** para atestar isenção.

## 5. Princípios de Governança

*   **Uso Secundário Estritamente Vedado:** Tecnologicamente, nossos serviços e logs são regidos pelos SLAs e NDA. O uso cruzado para *Marketing*, *Analytics de negócio de terceiros* ou repasse a demais Controladores é expressamente proibido pela política de engenharia.
*   **Subcontratados em Nuvem:** Para as hospedagens remotas (AWS/Azure/GCP), as premissas atestam obrigatoriamente "Cláusulas Padronizadas" referenciadas internacionalmente e SOC2 integrando salvaguardas equivalentes na custódia hermética de recursos. 

## 6. Disposições Finais

O descumprimento intencional interno desta Política sujeitará falhas a rigores sancionatórios administrativos cabíveis de rescisão enquadrados por "Violação ao Termo de Colaboração Normativo da Perceptiva".

Dúvidas referentes a esta política devem ser sanadas pela Área de Compliance e Governança da Perceptiva (dpo@perceptiva.tech).
