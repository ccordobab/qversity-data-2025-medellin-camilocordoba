{{ config(materialized='table') }}
-- How are customers distributed across different operators?
select
    operator,
    count(*) as customer_count,
    current_timestamp as report_generated_at
from {{ ref('silver_customers') }}
group by operator
order by customer_count