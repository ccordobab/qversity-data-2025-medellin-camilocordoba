{{ config(materialized='table') }}
-- How do the mean and median monthly revenues per user compare across different plan types and operators?
with stats as (
    select
        plan_type,
        operator,
        avg(monthly_bill_usd) as mean_revenue,
        percentile_cont(0.5) within group (order by monthly_bill_usd) as median_revenue,
        count(*) as user_count
    from {{ ref('silver_customers') }}
    group by plan_type, operator
)

select *, current_timestamp as report_generated_at
from stats
order by plan_type, operator
