{{ config(materialized='table') }}

select
    d.device_brand,
    p.plan_type,
    count(*) as device_count
from {{ ref('silver_customers') }} as c
join {{ ref('silver_devices') }} as d on c.device_id = d.device_id
join {{ ref('silver_plans') }} as p on c.customer_clean_id = p.customer_clean_id
group by d.device_brand, p.plan_type
order by device_count desc