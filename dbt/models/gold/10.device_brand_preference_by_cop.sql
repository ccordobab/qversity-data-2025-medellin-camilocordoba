{{ config(materialized='table') }}

select
    d.device_brand,
    l.country,
    c.operator,
    count(*) as device_count
from {{ ref('silver_customers') }} as c
join {{ ref('silver_devices') }} as d on c.device_id = d.device_id
join {{ ref('silver_locations') }} as l on c.location_id = l.location_id
group by d.device_brand, l.country, c.operator
order by device_count desc