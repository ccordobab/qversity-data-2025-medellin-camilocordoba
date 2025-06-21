{{ config(materialized='table') }}

select
    sg.service_group_id,
    string_agg(distinct s.service, ', ' order by s.service) as service_combination,
    count(distinct mcs.customer_id) as total_customers,
    current_timestamp as report_generated_at
from {{ ref('silver_map_customer_services') }} mcs
join {{ ref('silver_service_groups') }} sg on mcs.service_group_id = sg.service_group_id
join {{ ref('silver_services') }} s on sg.service_id = s.service_id
group by sg.service_group_id
order by total_customers desc