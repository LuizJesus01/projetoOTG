{% docs __overview__ %}

# 🛡️ Projeto OTG - Pipeline de Detecção de Fraudes & Marketing

Bem-vindo à documentação oficial do **projetoOTG**, uma solução de Engenharia de Dados desenvolvida para estruturar e tratar dados heterogêneos de comportamento e finanças focada na mitigação de riscos e análise de performance.

---

### 🏗️ Arquitetura do Projeto (Medallion)

O pipeline de dados foi desenhado seguindo a arquitetura Medallion dentro do **Google BigQuery**, garantindo governança, qualidade e rastreabilidade:

1. **Camada Bronze (Staging):** Mapeia as fontes brutas (`raw_data`) ingeridas pelo Airflow. Realiza a limpeza inicial, higienização de strings e padronização de tipos de dados (`Views`).
2. **Camada Silver (Intermediate):** Cruza e enriquece os dados limpos. Consolida agregados de comportamento de navegação (Sessões/IPs) e histórico financeiro por jogador (`Tabelas`).
3. **Camada Gold (Marts):** Camada final otimizada para consumo analítico (Power BI). Dividida em:
   * **Fraud:** Modelos de inteligência com regras automatizadas para detecção de lavagem de dinheiro e abuso de contas (*Multi-accounting*).
   * **Marketing:** Indicadores de performance de afiliados (CPA, cliques e conversões) cruzados com métricas de risco.

---

### 🎛️ Stack Tecnológica Utilizada
* **Orquestração:** Apache Airflow (Simulado na carga inicial).
* **Armazenamento e Computação:** Google BigQuery.
* **Transformação de Dados:** dbt (Data Build Tool) Core.
* **Qualidade de Dados:** Testes nativos de integridade do dbt (`unique`, `not_null`, `accepted_values`).

---

*Clique no botão redondo azul no canto inferior direito para visualizar o **Gráfico de Linhagem (Lineage Graph)** de ponta a ponta do projeto.*

{% enddocs %}
