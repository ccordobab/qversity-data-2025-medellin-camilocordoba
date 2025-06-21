{{ config(materialized='table') }}


select
    l.country,
    l.city,
    sum(c.monthly_bill_usd) as total_revenue
from {{ ref('silver_customers') }} as c
join {{ ref('silver_locations') }} as l on c.location_id = l.location_id
where c.monthly_bill_usd is not null
group by country, city
order by total_revenue desc
