from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator
from airflow.operators.bash import BashOperator

# Configurações padrão para as tarefas da DAG
default_args = {
    'owner': 'Luiz - Engenharia de Dados',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id='pipeline_automatizada_fraude_otg',
    default_args=default_args,
    description='Pipeline Fim a Fim: Ingestão de Arquivos Heterogêneos (GCS -> BigQuery) + Transformações dbt Medallion',
    schedule='@daily',
    start_date=datetime(2026, 7, 1),
    catchup=False,
    tags=['ingestao', 'gcs', 'dbt', 'fraude'],
) as dag:

    # =========================================================================
    # CAMADA DE INGESTÃO AUTOMATIZADA (GCS para Tabelas Brutas do BigQuery)
    # =========================================================================

        # 1. Ingestão da tabela de Jogadores (Ajustado com o parâmetro oficial quote_character)
    ingerir_players = GCSToBigQueryOperator(
        task_id='ingest_players_json',
        bucket='projeto0tg',
        source_objects=['landing_zone/players/players.json'],
        destination_project_dataset_table='projetootg.raw_data.players',
        source_format='CSV',                               # Forçamos texto para ler o array complexo
        field_delimiter='\x01',                             # Delimitador invisível que engole a linha toda
        quote_character="",                             # <-- O nome correto do parâmetro oficial do Airflow!
        allow_quoted_newlines=True,                         # Permite ler o arquivo respeitando as quebras de linha
        write_disposition='WRITE_TRUNCATE',
        gcp_conn_id='google_cloud_default'
    )

    # 2. Ingestão da tabela de Sessões (Ajustado com o parâmetro oficial quote_character)
    ingerir_sessions = GCSToBigQueryOperator(
        task_id='ingest_sessions_json',
        bucket='projeto0tg',
        source_objects=['landing_zone/sessions/sessions.json'],
        destination_project_dataset_table='projetootg.raw_data.sessions',
        source_format='CSV',
        field_delimiter='\x01',
        quote_character="",                             # <-- Aplicado aqui também!
        allow_quoted_newlines=True,
        write_disposition='WRITE_TRUNCATE',
        gcp_conn_id='google_cloud_default'
    )

    # 3. Ingestão da tabela de Transações Financeiras (CSV)
    ingerir_transactions = GCSToBigQueryOperator(
        task_id='ingest_transactions_csv',
        bucket='projeto0tg',
        source_objects=['landing_zone/transactions/transactions.csv'],
        destination_project_dataset_table='projetootg.raw_data.transactions',
        source_format='CSV',
        skip_leading_rows=1,                                        # Pula a linha de cabeçalho do CSV
        write_disposition='WRITE_TRUNCATE',
        gcp_conn_id='google_cloud_default'
    )

    # 4. Ingestão da tabela de Performance de Afiliados (CSV)
    ingerir_affiliates = GCSToBigQueryOperator(
        task_id='ingest_affiliates_csv',
        bucket='projeto0tg',
        source_objects=['landing_zone/affiliate_cpa_ftd/affiliate_cpa_ftd.csv'],
        destination_project_dataset_table='projetootg.raw_data.affiliate_cpa_ftd',
        source_format='CSV',
        skip_leading_rows=1,
        write_disposition='WRITE_TRUNCATE',
        gcp_conn_id='google_cloud_default'
    )

    # =========================================================================
    # CAMADA DE TRANSFORMAÇÃO E GOVERNANÇA (Execução dos comandos dbt)
    # =========================================================================
    
    # 5. Roda os testes de qualidade nas chaves primárias e valores aceitos da Staging
    testar_fontes_bronze = BashOperator(
        task_id='dbt_test_sources',
        bash_command='cd /usr/local/airflow/include && DBT_TARGET_PATH=/tmp/dbt_target dbt --log-path /tmp test --select staging --profiles-dir /usr/local/airflow/include'
    )

    # 6. Compila e processa as tabelas limpas e calculadas (Bronze -> Silver -> Gold)
    executar_transformacao_medallion = BashOperator(
        task_id='dbt_run_pipeline',
        bash_command='cd /usr/local/airflow/include && DBT_TARGET_PATH=/tmp/dbt_target dbt --log-path /tmp run --profiles-dir /usr/local/airflow/include'
    )


    # =========================================================================
    # DEFINIÇÃO DA ORQUESTRAÇÃO DO PIPELINE
    # =========================================================================
    # Os quatro arquivos brutos são baixados do GCS e carregados no BQ em paralelo de uma só vez.
    # Quando todas as 4 ingestões terminarem com sucesso, o Airflow dispara a malha de testes.
    # Se os testes de qualidade passarem, o dbt reconstrói a pipeline analítica Medallion.
    [ingerir_players, ingerir_sessions, ingerir_transactions, ingerir_affiliates] >> testar_fontes_bronze >> executar_transformacao_medallion
