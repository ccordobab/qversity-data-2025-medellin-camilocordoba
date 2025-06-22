{{ config(materialized='table') }}

-- Which customers have pending payments?

select distinct customer_id, current_timestamp as report_generated_at
from {{ ref('silver_payment_history') }}
where trim(lower(status)) = 'pending'

