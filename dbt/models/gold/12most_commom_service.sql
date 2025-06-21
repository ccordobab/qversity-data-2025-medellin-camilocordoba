{{ config(materialized='table') }}

select
    s.service,
    count(distinct mcs.customer_id) as total_customers
from {{ ref('silver_map_customer_services') }} mcs
join {{ ref('silver_service_groups') }} sg on mcs.service_group_id = sg.service_group_id
join {{ ref('silver_services') }} s on sg.service_id = s.service_id
group by s.service
order by total_customers desc
