{{ config(materialized='table') }}
-- Which customer segments generate the highest revenue?

with base as (
    select
        customer_id,
        age,
        monthly_bill_usd
    from {{ ref('silver_customers') }}
    where age is not null and monthly_bill_usd is not null
),

segmented as (
    select
        case
            when age < 18 then 'Under 18'
            when age >= 18 and age < 25 then '18-24'
            when age >= 25 and age < 35 then '25-34'
            when age >= 35 and age < 45 then '35-44'
            when age >= 45 and age < 60 then '45-59'
            else '60+'
        end as age_segment,
        monthly_bill_usd
    from base
)

select
    age_segment,
    count(*) as customer_count,
    sum(monthly_bill_usd) as total_revenue,
    avg(monthly_bill_usd) as avg_revenue_per_user,
    current_timestamp as report_generated_at
from segmented
group by age_segment
order by total_revenue desc
