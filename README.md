# Qversity Data Final Project 2025

## Overview

This project implements a complete end-to-end ELT data pipeline using the Medallion Architecture (Bronze, Silver, Gold). The main goal is to integrate the data engineering tools learned during the Qversity training, and extract business insights from a custom dataset.

The dataset used is a messy JSON file stored in a public S3 bucket, containing information about mobile service customers. This pipeline ingests the data, transforms it through successive layers, and ultimately provides business-ready tables that answer real-world analytical questions.

**Technologies used:**

- Docker
- PostgreSQL
- Apache Airflow
- dbt
- Python
- Git & GitHub

---

## Author

- **Name**: Camilo Cordoba Bedoya
- **Email**: camilocb204@gmail.com  
- **City**: Medellín  
- **Cohort**: Qversity 2025  

---

## Quick Start

### Requirements

- Docker & Docker Compose
- Python 3.11+
- dbt-postgres

---

## Bronze Layer – Raw Ingestion

### Goal
Store the raw JSON data as-is from the public S3 bucket, preserving its original structure while adding basic metadata for traceability ("ingestion_timestamp").

### Tools Used
- **Apache Airflow** for orchestration
- **Python** for data handling
- **pandas** for DataFrame processing
- **SQLAlchemy** for database connectivity
- **PostgreSQL** as the storage layer

### Actions Taken

- A Python-based Airflow DAG was created to orchestrate the ingestion process.
- The DAG downloads the JSON file from the following public S3 endpoint:
https://qversity-raw-public-data.s3.amazonaws.com/mobile_customers_messy_dataset.json
- The raw data is parsed into a DataFrame using pandas and stored in PostgreSQL in the table: bronze_mobile_customers
- An additional column ingestion_timestamp is added to each record to capture the load time.
- The ingestion task uses to_sql to convert the DataFrame into a PosfgreSQL table.

- To promote clean code and reuse, a dedicated module utils.py was created to hold helper functions for data extraction and serialization.




