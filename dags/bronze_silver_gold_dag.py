from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from datetime import datetime
import os
import requests
import pandas as pd
from sqlalchemy import create_engine
import json
from utils import serialize_json, json_from_api

URL = "https://qversity-raw-public-data.s3.amazonaws.com/mobile_customers_messy_dataset.json"

# function defined in utils.py to request the data from the S3 bucket and returning the data of the response object without the metadata
json_data = json_from_api(URL)

# transforms the json a postgreSQL table with a timestamp column added for the ingestion time
def converting_json_to_table_with_timestamp():

    # converts JSON file to a pandas DataFrame
    mobile_customer_dataframe = pd.DataFrame(json_data)

    # the 'payment_history' colummn contains nested data (dictionaries list), therefore it is serialized to JSON string so that it can be stored in a table
    mobile_customer_dataframe['payment_history'] = mobile_customer_dataframe['payment_history'].apply(serialize_json)
    mobile_customer_dataframe['ingestion_timestamp']= datetime.now()
    engine = create_engine("postgresql+psycopg2://qversity-admin:qversity-admin@postgres:5432/qversity")

    # exports the dataframe to an SQL table
    mobile_customer_dataframe.to_sql(
        name='bronze_mobile_customers',
        con=engine,
        schema='public',
        if_exists='replace', 
        index=False
    )
    engine.dispose()

with DAG(
    dag_id="bronze_silver_gold",
    start_date=datetime(2024, 1, 1),
    schedule_interval=None,
    catchup=False,
    tags=["medallion"],
) as dag:

    # task to execute the ingestion from the json bucket to the postgreSQL bronze_mobile_customer_table
    bronze_raw_table_creation_task = PythonOperator(
        task_id = "bronze_raw_table_creation_from_json",
        python_callable = converting_json_to_table_with_timestamp,
    )

    run_dbt_silver_task = BashOperator(
        task_id="run_dbt_silver_models",
        bash_command="docker exec qversity-dbt-1 dbt run --select silver",
    )

    run_dbt_gold_task = BashOperator(
        task_id="run_dbt_gold_models",
        bash_command="docker exec qversity-dbt-1 dbt run --select gold",
    )

    bronze_raw_table_creation_task >> run_dbt_silver_task
    run_dbt_silver_task >> run_dbt_gold_task
