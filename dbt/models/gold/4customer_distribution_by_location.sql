{{ config(materialized='table') }}
--What is the distribution of customers by location?
select
    l.country,
    l.city,
    count(*) as customer_count,
    current_timestamp as report_generated_at
from {{ ref('silver_customers') }} as c
join {{ ref('silver_locations') }} as l on c.location_id = l.location_id
group by l.country, l.city
order by customer_count desc
