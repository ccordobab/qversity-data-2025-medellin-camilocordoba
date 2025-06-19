{{ config(materialized='table') }}

with raw_devices as (
    select
        device_brand,
        device_model
    from {{ ref('silver_staging_mobile_customers') }}
    where device_brand is not null and device_model is not null
    group by device_brand, device_model
),

with_ids as (
    select *,
        row_number() over (order by device_brand, device_model) as device_id
    from raw_devices
)

select * from with_ids
