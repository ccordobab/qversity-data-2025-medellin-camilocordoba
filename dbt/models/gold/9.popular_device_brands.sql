{{ config(materialized='table') }}

select
    d.device_brand,
    count(*) as device_count
from {{ ref('silver_customers') }} as c
join {{ ref('silver_devices') }} as d on c.device_id = d.device_id
group by d.device_brand
order by device_count desc