# Plano de Resposta a Incidentes de Segurança da Informação
**Empresa:** Perceptiva
**Data da Última Revisão:** Outubro/2025
**Versão:** 1.0

## 1. Objetivo

Este **Plano de Resposta a Incidentes de Segurança da Informação** define a metodologia da **Perceptiva** para gerenciar, mitigar, comunicar e remediar incidentes cibernéticos ou violações de dados, assegurando a continuidade dos serviços prestados na nossa infraestrutura de API Gateway e reduzindo impactos para a Perceptiva e para nossos Clientes e Parceiros (tais como a Pottencial Seguradora).

## 2. Abrangência e Equipe

Este plano aplica-se a toda a infraestrutura física e lógica da empresa.
A **Equipe de Resposta a Incidentes (ERT - Incident Response Team)**: Composta pelo líder de Segurança (CISO/SecOps), Líderes de Engenharia (SRE/DevOps) e o Encarregado de Dados (DPO) da Perceptiva.

## 3. Classificação e Triagem do Evento

Fomentados pelo monitoramento ativo 24/7 (SIEM/APM) e alertas acionados na nuvem, categorizamos eventos sob três prismas principais:

*   **P1 - Crítico (Emergência):** Indício claro de sistema comprometido, brecha ativada de dados na camada administrativa (Control Plane) ou paralisação por ataques volumétricos (DDoS massivo). **SLA de Resposta Inicial:** 15 a 30 minutos.
*   **P2 - Alto (Alerta Maior):** Anomalia de rede isolada ou infecção por malware interceptada e mitigada preventivamente no endpoint sem escalonamento ao core. Tende à contenção do "Tenant". **SLA Inicial:** 1h a 2h.
*   **P3 - Médio/Baixo (Falso Positivo / Risco Futuro):** Picos isolados de tráfego (Rate Limiting WAF deflagrado com sucesso), logins mal-sucedidos iterativamente refreados pelo IAM, bloqueio de port scanning.

## 4. Fases da Gestão de Incidentes

O clico de Resposta Baseia-se no framework SANS / NIST SP 800-61.

### Fase 1: Preparação
*   Monitoramento SIEM na AWS/GCP (CloudWatch ou parceiro de Datadog).
*   Manutenção do cofre de acessos e VPN.
*   Conscientização semestral (Treinamentos Phishing).

### Fase 2: Identificação e Alerta
*   Ativação formal via PagerDuty (ou equivalente on-call) à equipe de SRE confirmando a suspeita fática de ofensa P1 ou P2 aos sistemas Perceptiva através da telemetria e das dashboards (Spikes 5xx irregulares).

### Fase 3: Contenção
*   Estratégia de Curto Prazo com prioridade imediata para "Sangrar o Tráfego": Isolamento da VPC/Sub-rede do Container injetado; rotação de credentials (API Keys expiradas sob revogação mandatória via IdP e Segredos Criptográficos rotacionados via cofre Master).
*   Desvio de Rotas: Configuração do WAF da "Edge" com regras contíguas (Rate Limiting de IPs nocivos hostis).

### Fase 4: Comunicação Contratual

Em conformidade à premissa técnica com **Dados Pessoais B2B do Cliente** (pressionados pelo Marco Civil / LGPD / Banco Bacen/Susep):

1.  Se o tráfego em rede pass-through da **Pottencial Seguradora** (cliente) for alvo de intercepção lateral crível ou expurgo sistêmico na API Gateway da locatária (Ataque P1 na infra Perceptiva)...
2.  A Equipe ERT está obrigada a **Comunicar oficialmente a Área de Segurança da Informação da Pottencial** *o mais rápido possível*, preterindo e adiantando investigações formais mais lentas (Aviso Primário da Crise em < 2 horas).
3.  Embora não retidos perenemente, metadados efêmeros comprometidos em trânsito exigem do cliente-parceiro uma notificação sistêmica ao Titular de Direito em acordo a LGPD regulacional sob D+2 úteis. 

### Fase 5: Erradicação e Recuperação
*   Deploy (Rollback/Roll-forward) Imutável com o Path limpo proveniente do código-fonte atestado.
*   Reinjeção da instância de roteamento do tráfego.

### Fase 6: Lições Aprendidas (Post-Mortem)
*   Até 5 (cinco) dias letivos subsequenciais à mitigação do Crítico (P1): Elaboração compulsória do Documento Formal RCA (Root Cause Analysis - Post-Mortem "Blameless"), gerando inputs para as áreas de Engenharia e correção do Playbook Interno perante novas vulnerabilidades.
