{{ config(materialized='table') }}

-- What is the average revenue per user ARPU) by plan type?

select
    plan_type,
    avg(monthly_bill_usd) as arpu,
    current_timestamp as report_generated_at
from {{ ref('silver_customers') }}
where monthly_bill_usd is not null
group by plan_type
order by arpu desc
