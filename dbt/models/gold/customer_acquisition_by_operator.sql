{{ config(materialized='table') }}
-- What are customer acquisition trends by operator?
select
    date_trunc('month', c.registration_date) as month,
    c.operator,
    count(*) as new_customers,
    current_timestamp as report_generated_at
from {{ ref('silver_customers') }} c
where c.registration_date is not null
group by month, c.operator
order by month, c.operator
