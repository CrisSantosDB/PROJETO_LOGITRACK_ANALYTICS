# 🚚 LogiTrack Analytics - Modern Data Lakehouse na Azure

[![CI Pipeline](https://github.com/CrisSantosDB/PROJETO_LOGITRACK_ANALYTICS/actions/workflows/ci.yml/badge.svg)](https://github.com/CrisSantosDB/PROJETO_LOGITRACK_ANALYTICS/actions/workflows/ci.yml)
[![CD Pipeline](https://github.com/CrisSantosDB/PROJETO_LOGITRACK_ANALYTICS/actions/workflows/cd.yml/badge.svg)](https://github.com/CrisSantosDB/PROJETO_LOGITRACK_ANALYTICS/actions/workflows/cd.yml)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-844FBA?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Cloud-Microsoft_Azure-0078D4?logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com/)
[![Apache Spark](https://img.shields.io/badge/Engine-Apache_Spark_3.5-E25A1C?logo=apache-spark&logoColor=white)](https://spark.apache.org/)

<p align="center">
  <img src="https://github.com/CrisSantosDB/PROJETO_LOGITRACK_ANALYTICS/blob/main/docs/arquitetura_telemetria.png?raw=true" alt="Arquitetura da Solução" width="1000">
</p>


---

## 📌 Visão Geral do Projeto

O **LogiTrack Analytics** é uma plataforma de engenharia de dados ponta a ponta projetada para ingestão, processamento e análise de dados de telemetria logística e operações de transporte em tempo real e em lote (*batch*). 

O projeto adota a arquitetura **Medallion (Bronze/Silver/Gold)** e implementa práticas modernas de **DataOps**, com toda a infraestrutura provisionada via **Terraform** e integrada a esteiras automatizadas de **CI/CD no GitHub Actions**.

---

## 🎯 Contexto de Negócio: A Dor do Setor Logístico

Empresas de logística, transporte e armazenagem lidam diariamente com um volume massivo de leituras geradas por frotas e centros de distribuição. Sem uma arquitetura analítica estruturada, a operação enfrenta:

* **Silos de Dados e Falta de Visão Unificada:** Leituras de sensores de armazém (temperatura e umidade) e telemetria veicular (velocidade, combustível e rotas) ficam isoladas em formatos brutos, dificultando o cruzamento de dados.
* **Perdas na Cadeia Fria (*Cold Chain*):** Atrasos na identificação de eventos fora do padrão térmico em armazéns de perecíveis ou farmacêuticos geram risco de perda de carga.
* **Falta de Rastreabilidade Operacional em Eventos de Frota:** Dificuldade de auditar eventos pontuais de excesso de velocidade ou alertas de combustível por veículo e data.
* **Alto Custo de Armazenamento e Consulta:** Consultar dados brutos sem padronização de tipos e sem modelagem estruturada encarece a nuvem e torna as consultas lentas.
* **Falta de Governança na Infraestrutura:** Recursos de nuvem criados de forma manual e sem versionamento aumentam o risco de erros operacionais e falta de controle de custos.

---
## 💼 Impacto Estratégico & Valor de Negócio

A plataforma **LogiTrack Analytics** transforma grandes volumes de dados brutos de sensores em inteligência de negócios, gerando valor direto em três pilares fundamentais da operação logística:

---

### 1. 🛡️ Proteção de Cargas & Redução de Prejuízos Operacionais
* **Garantia da Cadeia Fria (*Cold Chain*):** Monitoramento contínuo das condições térmicas e de umidade nos centros de distribuição, prevenindo perdas de lotes de produtos perecíveis e farmacêuticos.
* **Segurança e Conformidade de Frotas:** Visibilidade detalhada sobre eventos críticos de condução (excessos de velocidade e alertas de combustível), aumentando a segurança dos motoristas e a conservação dos veículos.

---

### 2. 💰 Eficiência Financeira & Redução de Custos Operacionais
* **Otimização de Custos de Armazenamento:** Estruturação inteligente dos dados para evitar acúmulo desnecessário de volume bruto, reduzindo despesas com infraestrutura de nuvem.
* **Agilidade na Tomada de Decisão:** Informações processadas e organizadas para consulta rápida, permitindo que a liderança tome decisões operacionais em minutos em vez de horas.

---

### 3. 🚀 Governança, Confiabilidade & Padronização
* **Processos Livres de Erros Manuais:** Ambiente totalmente padronizado e automatizado, eliminando falhas humanas na entrega e manutenção dos sistemas analíticos.
* **Auditabilidade e Histórico Confiável:** Centralização segura de todas as leituras da operação, garantindo base de dados auditável para compliance, laudos regulatórios e relatórios executivos.

---

## 🏛️ Arquitetura da Solução

```text
[ Dispositivos IoT / Veículos ]
              │ (Telemetria)
              ▼
       [ Azure IoT Hub ]
              │
              ▼
   [ Azure ADLS Gen2 (Bronze) ] ────► Armazenamento Raw (JSON / Parquet)
              │
              ▼ (Apache Spark 3.5 / Synapse)
   [ Azure ADLS Gen2 (Silver) ] ────► Dados limpos, enriquecidos e tipados
              │
              ▼ (Modelagem Dimensional - Star Schema)
   [ Azure ADLS Gen2 (Gold) ]   ────► Tabelas Fato e Dimensão agregadas
              │
              ▼
 [ Azure Synapse SQL / Power BI ] ──► Dashboards e Análise Operacional
```

### Componentes Principais:
* **Azure IoT Hub:** Ponto de entrada de telemetria dos sensores veiculares.
* **Azure Data Lake Storage Gen2 (ADLS Gen2):** Armazenamento hierárquico estruturado em camadas (*Bronze, Silver, Gold*).
* **Azure Synapse Analytics & Spark Pool:** Processamento distribuído com Apache Spark 3.5 para transformação e limpeza dos dados.
* **Azure Data Explorer (Kusto Cluster):** Consulta e análise analítica de séries temporais de alta frequência.
* **Terraform:** Provisionamento e versionamento declarativo de toda a infraestrutura em nuvem (*IaC*).
* **GitHub Actions:** Esteiras de Integração Contínua (CI) e Entrega Contínua (CD).

---

## ⚙️ Esteira de CI/CD (DataOps / GitOps)

O projeto conta com pipelines automatizados no GitHub Actions para garantir governança de código e deploys seguros:

```text
Feature Branch ────► Pull Request ────► CI Pipeline (Lint, Format, Validate)
                                              │ (Aprovação)
                                              ▼
                                         Merge na main
                                              │
                                              ▼
                                     CD Pipeline (Deploy)
                                              ├── Autenticação Azure
                                              ├── Leitura do State Remoto (Blob tfstate)
                                              └── terraform apply (Deploy Automático)
```

1. **Continuous Integration (CI):**
   * Disparado em pull requests e pushes na branch `main`.
   * Valida sintaxe (`terraform validate`) e formatação (`terraform fmt -check`).
2. **Continuous Deployment (CD):**
   * Disparado automaticamente após merge na branch `main`.
   * Conecta à Azure via Service Principal.
   * Utiliza **Remote Backend no Azure Blob Storage** (`tfstate`) com *state locking*.
   * Aplica idempotência via `terraform apply -auto-approve`.

---

## 📂 Estrutura do Repositório

```text
.
├── .github/
│   └── workflows/
│       ├── cd.yml                                # Pipeline de Deploy na Azure (Terraform Apply)
│       └── ci.yml                                # Pipeline de Validação (Terraform Fmt/Validate)
├── docs/
│   └── ADR-001-codificacao-numeric-status-telemetria.md  # Decisão de status numéricos
├── infra/                                        # Código Terraform (.tf)
├── synapse/
│   ├── credential/
│   ├── dataset/
│   ├── integrationRuntime/
│   ├── linkedService/
│   ├── notebook/                                 # Definições dos Notebooks do Synapse
│   │   ├── raw_vh_to_bronze_vh.json              # Ingestão Raw -> Bronze (Veículos)
│   │   ├── raw_wh_to_bronze_wh.json              # Ingestão Raw -> Bronze (Armazém)
│   │   ├── bronze_vh_to_silver_vh.json           # Transformação Bronze -> Silver (Veículos)
│   │   ├── bronze_wh_to_silver_wh.json           # Transformação Bronze -> Silver (Armazém)
│   │   ├── dim_data.json                         # Dimensão Calendário/Data
│   │   ├── gold_dim_vh.json                      # Dimensão Veículos
│   │   ├── gold_dim_wh.json                      # Dimensão Armazém
│   │   ├── gold_fct_vh.json                      # Tabela Fato Telemetria Veicular
│   │   └── gold_fct_wh.json                      # Tabela Fato Telemetria Armazém
│   └── pipeline/
│       └── publish_config.json
├── .gitignore
├── .python-version
├── main.py
├── pyproject.toml                                # Gerenciamento de dependências com UV
├── README.md
└── uv.lock
```


## 🛠️ Tecnologias Utilizadas

* **Linguagens & Engines:** Python, SQL, Apache Spark 3.5, HCL (HashiCorp Configuration Language)
* **Cloud & Armazenamento:** Microsoft Azure, Azure Data Lake Gen2, Azure Synapse Analytics, IoT Hub, Kusto Cluster
* **Infraestrutura e Automação:** Terraform, GitHub Actions, Azure CLI, Git

---

## 👤 Autora

Desenvolvido por **Cristina Santos**  

