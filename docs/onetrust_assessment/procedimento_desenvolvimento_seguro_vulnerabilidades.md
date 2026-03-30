# Procedimento de Desenvolvimento Seguro e Gestão de Vulnerabilidades
**Empresa:** Perceptiva
**Data da Última Revisão:** Outubro/2025
**Versão:** 1.0

## 1. Objetivo

A política e os procedimentos de **Desenvolvimento Seguro de Software (SDLC)** e **Gestão de Vulnerabilidades** da Perceptiva foram instituídos para blindar os ciclos de engenharia voltados à plataforma de API Gateway oferecida a empresas parceiras (Pottencial Seguradora), promovendo detecção proativa e remediação sistêmica contínua em toda pipeline de código-fonte.

## 2. Padrões de Desenvolvimento Seguro (SDLC)

1. **Versionamento e Commit Limpo:** Todo código gerado flui estritamente por versionamento central em repositórios corporativos controlados e restritos. Operamos política restritiva à ramificação "Main/Master" através de *Pull Requests (PRs)* onde revisores pares ("Code Review" obrigatório com aprovações por chaves PGP) assinam validando a conformidade legal do código (LGPD) e semântica antes do "Merge" automatizado.
2. **APIs e Design Orientado-a-Eventos:** Toda integração obedece à engenharia restrita do modelo REST:
   - Uso semântico correto dos verbos base HTTP (GET/POST/PUT/DELETE/PATCH) limitados aos padrões.
   - Todo fluxo de tráfego intermédio entre microserviços trafega com Malha Autenticada ("Service Mesh" interno base mTLS). Controles de Acesso são inatamente injetados na resposta de Backend via API e Edge, não sendo legados os limites ao "Cliente Frontal".
   - Todo "Sensible Data", API Keys e Tokens (Access Authentication Header) não figuram passivamente codados via query-strings nas URLs. Padrão estanque a OAuth2 e JWT.
3. **Modelagem de Ameaças Prévias (Threat Modeling):** Modificações expressivas subjacentes ("Architecture Decision Records") demandam análise precoce em fase de design sobre viabilidade do atacante, injeções em bancos NoSQL ou exaustões de Denial of Service (DoS) em borda, refutatórias atreladas a arquitetura Multi-Tenant isolada entre parceiros comerciais do API Gateway.

## 3. Integração Contínua e Ferramentas (SAST/DAST/SCA)

1.  **SAST (Static Application Security Testing):** O CI (Continuous Integration) da Perceptiva é automatizado. O escaneamento da conformidade do código perpassa por lints de engenharia e parsers baseados nos frameworks modernos nativos do OWASP Top 10 para eliminação orgânica da injeção no tempo de codificação.
2.  **SCA (Software Composition Analysis) / Dependabot:** Ferramentas rastreadoras avaliam incessantemente o grafo de dependências Open-Source e pacotes em Node/Golang, sugerindo PRs automatizados emergentes para suprir Common Vulnerabilities and Exposures (CVEs) recém flagradas e divulgadas nas linguagens.
3.  **DAST e PenTest:** Exames rigorosos periódicos (Dinâmicos) de intrusão autorizada atuam sobre portais administrativos e em endpoints expostos à "World Wide Web" via WAF restrito do cliente "Pass-Through". Caixas e instâncias imutáveis restritivas perentórias de ataques "Força Bruta" com Account Lockout e Limitação Rígida via IP Rate Limits (Fail2Ban).
  

## 4. Gestão de Patch Management e Remediações

Trabalhamos em um ecossistema com instâncias **Kubernetes Imutáveis / Infraestrutura como Código (IaC)**, prescindindo os clássicos cenários de aplicação manual de "Windows Updates" remotos via Sysadmin nas máquinas em tempo-real via SSH/RDP. Todo pacth é tratado na imagem base "golden configuration".

**Recorrência:**
*   **Ameaça Alta e Emergencial (CVE Zero-Day score >=9.0):** Ex.: Módulos primários expostos. Processo ad-hoc de compilação da master na nuvem ativado contíguo. O SLA de rollout do "Patch Pipeline" do tráfego atinge **Zero Downtime em período não-superante a 48 (quarenta e oito) horas ininterruptas**. 
*   **Demais Updates Regulares Sistêmicos e Bibliotecas de Baixo ou Padrão Risco:** Rollouts pacotes agrupados nos *Sprints Regulares (intervalos a cada ~14 dias)* das esteiras ativas, gerando updates homogêneos e previstos à esteira unificada de produção, sob a luzes das aprovações na janela Q/A e Staging do QA.
