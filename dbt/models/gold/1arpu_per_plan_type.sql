{{ config(materialized='table') }}

select
    plan_type,
    avg(monthly_bill_usd) as arpu
from {{ ref('silver_customers') }}
where monthly_bill_usd is not null
group by plan_type
order by arpu desc
