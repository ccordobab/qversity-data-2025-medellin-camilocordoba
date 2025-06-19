{{ config(materialized='table') }}

-- Step 1: Load base staging data
with base as (
    select * from {{ ref('silver_staging_mobile_customers') }}
),

-- Step 2: Join location dimension using cleaned city and country
joined_loc as (
    select
        b.customer_clean_id,
        b.original_customer_id,
        b.first_name,
        b.last_name,
        b.email,
        b.phone_number,
        b.age,
        b.registration_date,
        b.status,
        b.credit_score,
        b.ingestion_timestamp,
        b.transformation_timestamp,
        b.city,
        b.country,
        b.device_brand,
        b.device_model,
        loc.location_id
    from base b
    left join {{ ref('silver_locations') }} loc
        on b.city = loc.city
       and b.country = loc.country
),

-- Step 3: Join device dimension using cleaned device brand and model
joined_device as (
    select
        j.customer_clean_id,
        j.original_customer_id,
        j.first_name,
        j.last_name,
        j.email,
        j.phone_number,
        j.age,
        j.registration_date,
        j.status,
        j.credit_score,
        j.ingestion_timestamp,
        j.transformation_timestamp,
        j.location_id,
        d.device_id
    from joined_loc j
    left join {{ ref('silver_devices') }} d
        on j.device_brand = d.device_brand
       and j.device_model = d.device_model
)

-- Final selection: clean, enriched customer profile with foreign keys
select
    customer_clean_id,
    original_customer_id,
    first_name,
    last_name,
    email,
    phone_number,
    age,
    location_id,
    device_id,
    registration_date,
    status,
    credit_score,
    ingestion_timestamp,
    transformation_timestamp
from joined_device

