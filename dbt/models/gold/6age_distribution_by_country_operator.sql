{{ config(materialized='table') }}

select
    c.age,
    l.country,
    c.operator,
    count(*) as customer_count,
    current_timestamp as report_generated_at
from {{ ref('silver_customers') }} as c
join {{ ref('silver_locations') }} as l on c.location_id = l.location_id
group by c.age, l.country, c.operator
order by l.country, c.operator, c.age