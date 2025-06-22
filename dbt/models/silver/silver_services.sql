-- Purpose: Create a dimension table of all unique contracted services.
-- This table assigns a unique service_id to each cleaned service name.

{{ config(materialized='table') }}

-- Normalize and explode the 'contracted_services' array-like string into individual services
with exploded as (
    select
        lower(trim(service)) as service
    from {{ ref('silver_staging_mobile_customers') }},
    -- Remove curly braces and whitespace, then split by comma into array elements
    lateral unnest(string_to_array(
        regexp_replace(regexp_replace(contracted_services, '[{}]', '', 'g'), '\s+', '', 'g'),
        ','
    )) as service
),

-- Remove duplicates to get a clean list of distinct services
cleaned as (
    select distinct service
    from exploded
)

-- Assign a unique ID to each service
select
    row_number() over (order by service) as service_id,
    service,
    current_timestamp as processed_at
from cleaned

