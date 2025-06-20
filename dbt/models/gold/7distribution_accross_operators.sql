{{ config(materialized='table') }}

select
    operator,
    count(*) as customer_count
from {{ ref('silver_customers') }}
group by operator
order by customer_count