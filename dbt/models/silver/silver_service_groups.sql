{{ config(materialized='table') }}

-- Step 1: Explode service strings into rows and get their service_id
with exploded as (
    select
        customer_clean_id,
        s.service_id
    from {{ ref('silver_staging_mobile_customers') }} c,
    lateral unnest(
        string_to_array(
            regexp_replace(
                regexp_replace(lower(trim(contracted_services)), '[{}]', '', 'g'),
                '\s+', '', 'g'
            ),
            ','
        )
    ) as service_name
    inner join {{ ref('silver_services') }} s
        on lower(trim(service_name)) = s.service
    where contracted_services is not null
),

-- Step 2: For each customer, collect their services into a sorted array
customer_service_arrays as (
    select
        customer_clean_id,
        array_agg(distinct service_id order by service_id) as service_ids
    from exploded
    group by customer_clean_id
),

-- Step 3: Get unique combinations of service_ids arrays
distinct_combinations as (
    select distinct service_ids
    from customer_service_arrays
),

-- Step 4: Assign a group_id to each unique service_ids array
with_group_ids as (
    select
        row_number() over (order by service_ids) as service_group_id,
        service_ids
    from distinct_combinations
),

-- Step 5: Expand each group to map group_id ↔ service_id
unnested as (
    select
        g.service_group_id,
        unnest(g.service_ids) as service_id
    from with_group_ids g
)

-- Final result: each service_group_id and its corresponding service_ids
select 
    u.service_group_id,
    u.service_id,
    s.service
from unnested u
join {{ ref('silver_services') }} s
    on u.service_id = s.service_id
order by u.service_group_id, u.service_id



