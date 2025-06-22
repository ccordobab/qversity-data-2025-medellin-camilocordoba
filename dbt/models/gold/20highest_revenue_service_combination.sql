{{ config(materialized='table') }}

-- Which service combinations drive highest revenue?

with base as (
    select
        mcs.customer_id,
        mcs.service_group_id,
        p.monthly_bill_usd
    from {{ ref('silver_map_customer_services') }} mcs
    join {{ ref('silver_customers') }} p
        on mcs.customer_id = p.customer_id
    where p.monthly_bill_usd is not null
),

grouped as (
    select
        service_group_id,
        round(sum(monthly_bill_usd), 2) as total_revenue,
        count(*) as customer_count,
        round(avg(monthly_bill_usd), 2) as avg_revenue_per_user,
        current_timestamp as report_generated_at
    from base
    group by service_group_id
),

-- Paso 3: Obtenemos los nombres de los servicios combinados

service_names as (
    select
        sg.service_group_id,
        string_agg(distinct s.service, ', ' order by s.service) as service_combination
    from {{ ref('silver_service_groups') }} sg
    join {{ ref('silver_services') }} s
        on sg.service_id = s.service_id
    group by sg.service_group_id
)

select
    g.service_group_id,
    s.service_combination,
    g.customer_count,
    g.total_revenue,
    g.avg_revenue_per_user
from grouped g
join service_names s
    on g.service_group_id = s.service_group_id
order by g.total_revenue desc
