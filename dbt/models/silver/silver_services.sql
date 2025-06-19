{{ config(materialized='table') }}

-- we take the column `contracted_services` separating each individual service
with exploded as (
    select
        lower(trim(service)) as service
    from {{ ref('silver_staging_mobile_customers') }},
    -- curly braces `{}` are removed as well as all whitespace characters
    -- then the cleaned string is splited into an array and unnested to turn each array into individual rows
    lateral unnest(string_to_array(
        regexp_replace(regexp_replace(contracted_services, '[{}]', '', 'g'), '\s+', '', 'g'),
        ','
    )) as service
),

-- duplicates are deleted
cleaned as (
    select distinct service
    from exploded
)

select
    row_number() over (order by service) as service_id,
    service
from cleaned

