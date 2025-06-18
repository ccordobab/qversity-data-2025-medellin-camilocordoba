{{ config(materialized='table') }}
-- Este modelo no hace nada, solo expone la tabla que ya existe en Postgres
select * from public.bronze_raw_mobile_customers
