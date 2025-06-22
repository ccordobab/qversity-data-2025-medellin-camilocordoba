{{ config(materialized='table') }}

-- Extract unique city-country combinations from the silver_staging_mobile_customers table
with raw_locations as (
    select
        city,
        country
    from {{ ref('silver_staging_mobile_customers') }}
    where city is not null and country is not null
    group by city, country
),

-- Generate a location_id as a key
with_ids as (
    select *,
        row_number() over (order by country, city) as location_id
    from raw_locations
)

-- Return the final dimension table with location_id, city and country
select *, current_timestamp as processed_at from with_ids
