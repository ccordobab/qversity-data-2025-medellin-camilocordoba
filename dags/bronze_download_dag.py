from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
import os
import requests
import pandas as pd
from sqlalchemy import create_engine
import json
from utils import serialize_json, json_from_api

URL = "https://qversity-raw-public-data.s3.amazonaws.com/mobile_customers_messy_dataset.json"

# la función definida en utils.py para descargar y convertir el JSON a un objeto de Python. quitandole la metadata del objeto response
json_data = json_from_api(URL)

# Función principal que transforma el JSON a una tabla SQL con un timestamp de ingestión
def converting_json_to_table_with_timestamp():

    # Convertimos el JSON a un DataFrame de pandas
    mobile_customer_dataframe = pd.DataFrame(json_data)

    # La columna 'payment_history' contiene datos anidados (lista de diccionarios),
    # por lo tanto la serializamos como string JSON para que pueda guardarse en SQL
    mobile_customer_dataframe['payment_history'] = mobile_customer_dataframe['payment_history'].apply(serialize_json)
    mobile_customer_dataframe['ingestion_timestamp']= datetime.now()
    engine = create_engine("postgresql+psycopg2://qversity-admin:qversity-admin@postgres:5432/qversity")

    # Exportamos el DataFrame a una tabla SQL
    mobile_customer_dataframe.to_sql(
        name='bronze_mobile_customers',
        con=engine,
        schema='public',
        if_exists='replace', 
        index=False
    )
    engine.dispose()

with DAG(
    dag_id="download_bronze_silver_gold",
    start_date=datetime(2024, 1, 1),
    schedule_interval=None,
    catchup=False,
    tags=["medallion"],
) as dag:

    # tarea que ejecuta la función de ingestión
    bronze_raw_table_creation_task = PythonOperator(
        task_id = "bronze_raw_table_creation_from_json",
        python_callable = converting_json_to_table_with_timestamp,
    )


    bronze_raw_table_creation_task
