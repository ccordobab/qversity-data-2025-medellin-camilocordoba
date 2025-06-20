{{ config(materialized='table') }}


select
    l.country,
    l.city,
    sum(p.monthly_bill_usd) as total_revenue
from {{ ref('silver_plans') }} as p
join {{ ref('silver_customers') }} as c on p.customer_clean_id = c.customer_clean_id
join {{ ref('silver_locations') }} as l on c.location_id = l.location_id
where p.monthly_bill_usd is not null
group by country, city
order by total_revenue desc
