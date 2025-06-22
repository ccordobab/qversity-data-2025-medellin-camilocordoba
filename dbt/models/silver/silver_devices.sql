{{ config(materialized='table') }}

-- Extract unique combinations of device_brand and device_model
with raw_devices as (
    select
        device_brand,
        device_model
    from {{ ref('silver_staging_mobile_customers') }}
    where device_brand is not null and device_model is not null
    group by device_brand, device_model
),

-- Generate a unique key for each device
with_ids as (
    select *,
        row_number() over (order by device_brand, device_model) as device_id
    from raw_devices
)

-- Return the final dimension table with device_id, device_brand and device_model
select * , current_timestamp as processed_at from with_ids
