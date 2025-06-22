{{ config(materialized='table') }}
-- What are the most popular device brands?
select
    d.device_brand,
    count(*) as device_count,
    current_timestamp as report_generated_at
from {{ ref('silver_customers') }} as c
join {{ ref('silver_devices') }} as d on c.device_id = d.device_id
group by d.device_brand
order by device_count desc