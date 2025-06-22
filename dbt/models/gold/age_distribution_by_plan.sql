{{ config(materialized='table') }}
-- What is the age distribution of customers by plan type?
select
    age,
    plan_type,
    count(*) as customer_count,
    current_timestamp as report_generated_at
from {{ ref('silver_customers') }}
group by age, plan_type
order by plan_type, age desc
