# Política de Segurança da Informação
**Empresa:** Perceptiva
**Data da Última Revisão:** Outubro/2025
**Versão:** 1.0

## 1. Introdução e Objetivo

A Política de Segurança da Informação (PSI) da **Perceptiva** estabelece as diretrizes globais para garantir a Confidencialidade, Integridade e Disponibilidade (CID) de todos os ativos de informação lógicos e físicos, abrangendo infraestruturas próprias, ambientes na nuvem e redes de parceiros integradas. Nossa PSI está baseada nas melhores práticas mundiais (ISACA, CIS Controls, ISO 27001).

Esta é aplicável a todos os níveis hierárquicos: funcionários plenos, diretores, prestadores de serviço e terceiros com acesso aos ativos da Perceptiva.

## 2. Classificação da Informação

Toda informação na Perceptiva recebe uma classificação quanto ao seu grau de sigilo:
1.  **Pública:** Informações abertas ao mercado (ex: Site institucional, manuais públicos de API).
2.  **Uso Interno:** Políticas operacionais, organogramas corporativos.
3.  **Confidencial:** Dados estratégicos, códigos-fonte (Repositórios Privados), arquitetura de infraestrutura.
4.  **Estrita (Restrita):** Chaves criptográficas, certificados digitais (TLS), credenciais master de AWS/GCP, tokens IAM, metadados gerenciais com dados sensíveis de precificação da empresa. As informações de tráfego de clientes ("Pass-through") operam de forma opaca com grau de isolamento restrito na fronteira (Edge).

## 3. Conformidade, Riscos e Privacidade

*   **Matriz de Riscos:** A Perceptiva conduz revisões de escopo anuais (ou pós-mudanças estruturais) voltadas às ameaças de tecnologia (Vulnerabilidade) atrelada à Gestão de Riscos (Business Impact Analysis).
*   **Integração de Privacidade:** Em conjunto, a avaliação atende transversalmente as resoluções expostas na **Política de Privacidade e Proteção de Dados**, em compliance com os normativos LGPD, Marco Civil e diretrizes de provedores financeiros (ex: Regulamentações SUSEP 638 para seguradoras sob esteira tecnológica).

## 4. Gestão de Identidades e Acessos (IAM)

1.  **Concessão de Acesso (Onboarding):** Qualquer credenciamento basear-se-á no "Princípio do Menor Privilégio" (Least Privilege Policy). Padrões IAM via Provedores de Identidade (IdP) gerenciados atrelam o logon ao e-mail institucional corporativo.
2.  **Uso Compartilhado Expressamente Omitido:** Inexiste concessão de "Contas Genéricas" acessíveis via senha para a condução do painel de administração da plataforma Perceptiva por pares humanos. Administradores possuem trilha de "Audit Log" irrefutável. Contas de Sistemas operam em restrição sem TTY (Não-interativa).
3.  **Complexidade de Senha e MFA:** A política da Perceptiva impõe senhas longas/alfanuméricas, não reaproveitadas e alteradas no 1º login, além de exigir **Multi-Factor Authentication (MFA)** para todos os acessos, barrando conexões simultâneas que excedam a restrição sistêmica localizadas em IPs destoantes.
4.  **Coletes / Vaults:** Informações de acesso secretas aos bancos / subredes / certificados devem figurar imutavelmente encriptadas e armazenadas num Cofre (Secrets Manager / HashiCorp Vault), com trilhas de acesso restritas.
5.  **Revogação e Offboarding:** A perda da posição funcional, por dispensa ou encerramento motivado na relação corporativa, confere à equipe um SLA máximo de desativação total infraestrutural que não supere as **12 (doze) horas** comerciais.

## 5. Práticas Seguras para Uso de Ativos e Estações de Trabalho

### Dispositivos Móveis, BYOD e Notebooks:
*   Os equipamentos da Perceptiva possuem agentes **Antivírus (MDR/EDR)** homologados rodando ativamente e sem exceções, protegidos contra anulações intencionais.
*   **Criptografia Completa de Disco (FDE):** Todas as estações laborais (Laptops) contam com criptografia sistêmica no Boot (Ex: BitLocker, FileVault), protegendo hardware eventualmente perdido.
*   Mídias Removíveis Massivas externas, como Pen-drives ou HDDs portáteis, são bloqueadas nas subredes críticas corporativas visando anular Data Loss colateral (DLP físico).

### Acesso Remoto Seguro (VPN)
Trabalho e manutenção extra-muro (fora da LAN interna) ou que exija trânsito à VPC da plataforma hospedada requer estrito tunelamento por **Zero Trust Network Access (ZTNA) ou VPN forte (IPsec / SSL restrita)** amparada em certificado pessoal revogável expedido pela área de SRE e protegido por token biométrico.

## 6. Governança Operacional de Infraestrutura (Backup, Logs, Antivírus)

1.  **Registro Sistêmico (Logs):** Todo acesso efetuado ao Gateway (Acesso REST) é salvo com trilhamento seguro em provedores SIEM e centralizado (CloudWatch / Elastic) mantidos até 90 dias - com restritiva visualização.
2.  **Backups e Restauração Corporativa:**
    *   Sistemas de Painel de Controle, metadados gerenciais da nuvem / configuração infraestrutural da Perceptiva enquadram-se na varredura de Backups automáticos "Snapshot" operada pela Cloud provedora.
    *   Isenção pontual: Retificamos que as requisições geradas por nossos clientes através da API Management trafegam de modo efêmero ("Stateless"), isentando o espelhamento persistente da informação B2B na contingência. Empregamos DR (Disaster Recovery) para Uptime do tráfego.

## 7. Arquitetura de Redes e Segregação de Ambientes

Visando a estabilidade da plataforma e a segurança do código fonte frente a acessos indevidos, a tecnologia corporativa da Perceptiva adota mandatoriamente a estrita **segregação lógica e física de ambientes (VPC Isolation e Subredes)**:

1.  **Ambiente de Desenvolvimento (DEV):** Sandboxes isoladas para experimentação de engenharia e CI inicial. Sem conectividade de rede (VPC Peering) com bases de dados de parceiros ou painéis de administração.
2.  **Ambiente de Homologação e Qualidade (QA / UAT / Staging):** Réplica estrutural isolada da produção, utilizada unicamente para testes de qualidade, bateria de automação e testes de intrusão (PenTest). O acesso é fechado pela internet pública e protegido por WAF.
3.  **Ambiente de Produção (PRD):** A infraestrutura núcleo restrita ("Live"). Completamente segmentada em nuvem própria via contas separadas de IAM Billing e operada sob chaves criptográficas distintas. A comunicação entre os ambientes de DEV e PRD é estruturalmente cortada e bloqueada por Firewall (Zero-Trust Inter-Network routing). Nenhuma credencial de desenvolvedor de Sandbox possui valia técnica nos escopos PRD.

## 8. Penalidades e Comitê Punitivo

Omitir as prescrições ditadas, bem como tentar desativar escudos técnicos impostos pelas redes Perceptiva confere infração regimental e administrativa aos colaboradores, sob punição que avança da re-capacitação em Segurança à pronta ruptura da provisão laboral de Contrato (Justa Causa).
