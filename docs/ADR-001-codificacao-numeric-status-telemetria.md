# ADR 001: Utilização de Códigos Numéricos para Status e Alertas de Telemetria

* **Data:** 13 de Agosto de 2026
* **Status:** Aprovado
* **Autora:** Cristina
* **Contexto:** Camada Silver & Gold (Star Schema) - Pipeline de Telemetria

---

## Contexto e Problema

Nas camadas Silver de Armazém (`silver.tb_wh`) e Veículos (`silver.tb_vehicle`), são geradas métricas de alerta e status de telemetria em tempo real (ex: status de velocidade, temperatura, umidade e combustível). 

Inicialmente, avaliou-se salvar essas categorias como cadeias de texto descritivas (ex: `"EXCESSO_VELOCIDADE"`, `"ALERTA_ALTA"`). No entanto, o volume de eventos de telemetria é elevado e a Tabela Fato na camada Gold armazenará milhões de linhas de leituras.

---

## Decisão Aprovada

Decidiu-se **codificar todas as flags e status de evento utilizando números inteiros (`IntegerType`)** diretamente na Tabela Fato / Camada Silver, transferindo as descrições textuais para tabelas Dimensão de domínio ("De-Para") na camada Gold.

### Dicionário de Códigos (Mapeamento Domain)

#### Telemetria de Armazém (`silver.tb_wh`)
* **`status_temperatura`**: `1` = OK | `2` = ALERTA_ALTA | `3` = ALERTA_BAIXA
* **`status_umidade`**: `1` = OK | `2` = ALERTA_ALTA | `3` = ALERTA_BAIXO
* **`status_geral_armazem`**: `1` = NORMAL | `2` = CRITICO

#### Telemetria de Veículos (`silver.tb_vehicle`)
* **`status_velocidade`**: `1` = EM_MOVIMENTO | `2` = EXCESSO_VELOCIDADE | `3` = PARADO
* **`status_combustivel`**: `1` = NORMAL | `2` = ALERTA_BAIXO

---

## Justificativa Técnica & Benefícios

1. **Otimização de Armazenamento:** Inteiros (`INT`, 4 bytes) consomem significativamente menos espaço em disco e memória RAM do que *Strings* Parquet/Delta Lake.
2. **Performance de Consulta e Agrupamento:** Operações de `GROUP BY`, `WHERE` e `JOIN` em colunas numéricas possuem desempenho superior no Spark SQL e no motor VertiPaq do Power BI.
3. **Padrão Dimensional (Kimball):** A Tabela Fato permanece leve e enxuta, enquanto a camada descritiva é gerenciada via tabelas de Dimensão auxiliares ou modelo conceitual no Power BI.

---

## Consequências

* **Positivas:** Redução do custo de armazenamento em disco no ADLS Gen2, menor consumo de RAM do cluster no `readStream`/`writeStream` e otimização das consultas no Power BI.
* **Atenção:** As consultas SQL brutas na Fato exigirão um `JOIN` com as dimensões de status ou o uso do dicionário de códigos para interpretar o significado numérico (`1`, `2`, `3`).
