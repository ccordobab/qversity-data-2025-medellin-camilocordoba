{{ config(materialized='table') }}

with raw_locations as (
    select
        city,
        country
    from {{ ref('silver_staging_mobile_customers') }}
    where city is not null and country is not null
    group by city, country
),


with_ids as (
    select *,
        row_number() over (order by country, city) as location_id
    from raw_locations
)

select * from with_ids
