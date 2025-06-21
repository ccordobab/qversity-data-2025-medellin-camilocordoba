-- Purpose: Generate unique service groups (combinations of services) with IDs.

{{ config(materialized='table') }}

-- Normalize and explode service data
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
    -- Match each exploded service to its corresponding ID in the silver_services table
    inner join {{ ref('silver_services') }} s
        on s.service = service_name
    where contracted_services is not null
),

-- Group each customer's service_ids into ordered arrays
customer_service_arrays as (
    select
        customer_id,
        array_agg(distinct service_id order by service_id) as service_ids
    from exploded
    group by customer_id
),

-- Extract all distinct combinations of service_ids
distinct_combinations as (
    select distinct service_ids
    from customer_service_arrays
),

-- Assign a service_group_id to each unique combination
with_group_ids as (
    select
        row_number() over (order by service_ids) as service_group_id,
        service_ids
    from distinct_combinations
),

-- Explode each group back into (group_id, service_id) pairs
unnested as (
    select
        g.service_group_id,
        unnest(g.service_ids) as service_id -- Each service in the group becomes a row
    from with_group_ids g
)

-- Final output with service name included
select
    u.service_group_id,
    u.service_id,
    s.service
from unnested u
join {{ ref('silver_services') }} s
    on u.service_id = s.service_id
order by u.service_group_id, u.service_id



