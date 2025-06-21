{{ config(materialized='table') }}


select distinct customer_id
from {{ ref('silver_payment_history') }}
where trim(lower(status)) = 'pending'

