-- Purpose: Map each customer to a service group ID representing their unique combination of services.

{{ config(materialized='table') }}

-- Explode the raw contracted_services string field into individual normalized services per customer
with exploded as (
    select
        c.customer_id,
        s.service_id
    from {{ ref('silver_staging_mobile_customers') }} c,
    lateral unnest(string_to_array(
        regexp_replace(
            regexp_replace(lower(trim(contracted_services)), '[{}]', '', 'g'),
            '\\s+', '', 'g'
        ),
        ','
    )) as service_name
    -- Join with silver_services to get the service_id
    inner join {{ ref('silver_services') }} s
        on s.service = service_name
    where contracted_services is not null
),

-- For each customer, collect their ordered list of service IDs, Group each customer's services into a sorted array of service_ids
grouped_services as (
    select
        customer_id,
        array_agg(distinct service_id order by service_id) as service_ids,
        array_to_string(array_agg(distinct service_id order by service_id), ',') as service_ids_str
    from exploded
    group by customer_id
),

-- Get unique service combinations from service group model
distinct_service_groups as (
    select
        service_group_id,
        array_agg(service_id order by service_id) as service_ids,
        array_to_string(array_agg(service_id order by service_id), ',') as service_ids_str
    from {{ ref('silver_service_groups') }}
    group by service_group_id
),

-- Join each customer to their correct group using the stringified service array
mapped as (
    select
        g.customer_id,
        s.service_group_id,
        g.service_ids_str
    from grouped_services g
    join distinct_service_groups s
        on g.service_ids_str = s.service_ids_str
)

-- Final output
select
    customer_id,
    service_group_id,
    service_ids_str,
    current_timestamp as processed_at

from mapped
order by customer_id



