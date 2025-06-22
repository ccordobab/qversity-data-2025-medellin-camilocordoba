{{ config(materialized='table') }}
-- What is device brand preference by plan type?
select
    d.device_brand,
    c.plan_type,
    count(*) as device_count,
    current_timestamp as report_generated_at
from {{ ref('silver_customers') }} as c
join {{ ref('silver_devices') }} as d on c.device_id = d.device_id
group by d.device_brand, c.plan_type
order by device_count desc