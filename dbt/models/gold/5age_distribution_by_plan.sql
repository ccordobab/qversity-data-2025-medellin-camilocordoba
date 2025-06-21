{{ config(materialized='table') }}

select
    age,
    plan_type,
    count(*) as customer_count
from {{ ref('silver_customers') }}
group by age, plan_type
order by plan_type, age desc
