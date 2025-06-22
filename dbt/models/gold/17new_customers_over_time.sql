{{ config(materialized='table') }}
-- How does the distribution of new customers change over time?
select
    date_trunc('month', registration_date) as month,
    count(*) as new_customers,
    current_timestamp as report_generated_at
from {{ ref('silver_customers') }}
where registration_date is not null
group by month
order by month
