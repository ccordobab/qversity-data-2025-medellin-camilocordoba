from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
import os
import requests
import pandas as pd
from sqlalchemy import create_engine
import json

URL = "https://qversity-raw-public-data.s3.amazonaws.com/mobile_customers_messy_dataset.json"
LOCAL_PATH = "/opt/airflow/data/raw/mobile_customers_dataset.json"


def download_from_http():
    os.makedirs(os.path.dirname(LOCAL_PATH), exist_ok=True)
    response = requests.get(URL)
    response.raise_for_status() 
    with open(LOCAL_PATH, "w") as f:
        f.write(response.text)

def serialize_json(value):
    if isinstance(value, (dict,list)):
        try:
            return json.dumps(value)
        except Exception:
            return str(value)
    else:
        return str(value)

def converting_json_to_table():
    mobile_customer_dataframe = pd.read_json(LOCAL_PATH)
    mobile_customer_dataframe['payment_history'] = mobile_customer_dataframe['payment_history'].apply(serialize_json)
    mobile_customer_dataframe['ingestion_timestamp']= datetime.now()
    engine = create_engine("postgresql+psycopg2://qversity-admin:qversity-admin@postgres:5432/qversity")
    mobile_customer_dataframe.to_sql(
        name='bronze_raw_mobile_customers',
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
    tags=["bronze", "s3", "raw"],
) as dag:

    download_task = PythonOperator(
        task_id="download_json_from_http",
        python_callable=download_from_http,
    )

    bronze_raw_table_creation_task = PythonOperator(
        task_id = "bronze_raw_table_creation_from_json",
        python_callable = converting_json_to_table,
    )


    download_task >> bronze_raw_table_creation_task
