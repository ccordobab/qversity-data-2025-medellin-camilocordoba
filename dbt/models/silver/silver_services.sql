-- silver_services.sql
-- Purpose: Create a dimension table of all unique contracted services.
-- This table assigns a unique service_id to each cleaned service name.

{{ config(materialized='table') }}

with exploded as (
    select
        lower(trim(service)) as service
    from {{ ref('silver_staging_mobile_customers') }},
    lateral unnest(string_to_array(
        regexp_replace(regexp_replace(contracted_services, '[{}]', '', 'g'), '\s+', '', 'g'),
        ','
    )) as service
),

cleaned as (
    select distinct service
    from exploded
)

select
    row_number() over (order by service) as service_id,
    service
from cleaned

