{{ config(materialized='table') }}

with source as (
    select * from {{ ref('bronze_raw_mobile_customers') }}
),

cleaned as (
    select
        customer_id,
        initcap(trim(first_name)) as first_name,
        initcap(trim(last_name)) as last_name,
        lower(trim(email)) as email,
        trim(phone_number) as phone_number,
        case
            when cast(age as integer) between 18 and 110 then cast(age as integer)
            else null
        end as age,

        case
            when difference(lower(trim(country)), 'peru') >= 3 then 'peru'
            when difference(lower(trim(country)), 'argentina') >= 3 then 'argentina'
            when difference(lower(trim(country)), 'mexico') >= 3 then 'mexico'
            when difference(lower(trim(country)), 'colombia') >= 3 then 'colombia'
            when difference(lower(trim(country)), 'chile') >= 3 then 'chile'
            else lower(trim(country))
        end as country,

        case
            when difference(lower(trim(city)), 'cdmx') >= 3 then 'ciudad de mexico'
            when difference(lower(trim(city)), 'ciudad de mexico') >= 3 then 'ciudad de mexico'
            when difference(lower(trim(city)), 'guadalajara') >= 3 then 'guadalajara'
            when difference(lower(trim(city)), 'lima') >= 3 then 'lima'
            when difference(lower(trim(city)), 'arequipa') >= 3 then 'arequipa'
            when difference(lower(trim(city)), 'trujillo') >= 3 then 'trujillo'
            when difference(lower(trim(city)), 'medellin') >= 3 then 'medellin'
            when difference(lower(trim(city)), 'cali') >= 3 then 'cali'
            when difference(lower(trim(city)), 'bogota') >= 3 then 'bogota'
            when difference(lower(trim(city)), 'rosario') >= 3 then 'rosario'
            when difference(lower(trim(city)), 'santiago') >= 3 then 'santiago'
            when difference(lower(trim(city)), 'valparaiso') >= 3 then 'valparaiso'
            when difference(lower(trim(city)), 'concepcion') >= 3 then 'concepcion'
            when difference(lower(trim(city)), 'cordoba') >= 2 then 'cordoba'
            when difference(lower(trim(city)), 'buenos aires') >= 3 then 'buenos aires'
            when difference(lower(trim(city)), 'barranquilla') >= 3 then 'barranquilla'
            else lower(trim(city))
        end as city,

        case
            when difference(lower(trim(operator)), 'wom') >= 3 then 'wom'
            when difference(lower(trim(operator)), 'claro') >= 3 then 'claro'
            when difference(lower(trim(operator)), 'tigo') >= 3 then 'tigo'
            when difference(lower(trim(operator)), 'movistar') >= 2 then 'movistar'
            else lower(trim(operator))
        end as operator,

        case
            when difference(lower(trim(plan_type)), 'prepago') >= 2 then 'prepago'
            when difference(lower(trim(plan_type)), 'pospago') >= 2 then 'pospago'
            when difference(lower(trim(plan_type)), 'control') >= 2 then 'control'
            when difference(lower(trim(plan_type)), 'ctrl') >= 2 then 'control'
            else lower(trim(plan_type))
        end as plan_type,

        cast(monthly_data_gb as numeric) as monthly_data_gb,
        cast(monthly_bill_usd as numeric) as monthly_bill_usd,
        case
            when registration_date ~ '^\d{4}-\d{2}-\d{2}$' then to_date(registration_date, 'YYYY-MM-DD')
            when registration_date ~ '^\d{8}$' then to_date(registration_date, 'YYYYMMDD')
            when registration_date ~ '^\d{4}-\d{2}-\d{2}T' then to_date(left(registration_date, 10), 'YYYY-MM-DD')
            when registration_date ~ '^\d{2}-\d{2}-\d{4}$' then 
            case 
                when split_part(registration_date, '-', 1)::int > 12 then to_date(registration_date, 'DD-MM-YYYY')
                when split_part(registration_date, '-', 2)::int > 12 then to_date(registration_date, 'MM-DD-YYYY')
                else to_date(registration_date, 'DD-MM-YYYY')
            end
            else null
        end as registration_date,


        case
            when lower(trim(status)) in ('active', 'activo', 'válido') then 'activo'
            when lower(trim(status)) in ('inactive', 'inactivo', 'invalid') then 'inactivo'
            when lower(trim(status)) in ('suspended', 'suspendido') then 'suspendido'
            when trim(status) = '' or status is null then null
            else lower(trim(status))
        end as status,

        case
            when difference(lower(trim(device_brand)), 'apple') >= 3 then 'apple'
            when difference(lower(trim(device_brand)), 'samsung') >= 3 then 'samsung'
            when difference(lower(trim(device_brand)), 'xiaomi') >= 3 then 'xiaomi'
            when difference(lower(trim(device_brand)), 'huawei') >= 3 then 'huawei'
            else lower(trim(device_brand))
        end as device_brand,

        lower(trim(device_model)) as device_model,
        lower(trim(contracted_services)) as contracted_services,
        record_uuid,
        to_date(last_payment_date, 'YYYY-MM-DD') as last_payment_date,
        cast(credit_limit as numeric) as credit_limit,
        cast(data_usage_current_month as numeric) as data_usage_current_month,
        cast(latitude as float) as latitude,
        cast(longitude as float) as longitude,
        credit_score,
        ingestion_timestamp,
        payment_history,
        current_timestamp as transformation_timestamp
    from source
),

country_correction as (
    select  
        customer_id,
        first_name,
        last_name,
        email,
        phone_number,
        age,
        city,
        operator,
        plan_type,
        monthly_data_gb,
        monthly_bill_usd,
        registration_date,
        status,
        device_brand,
        device_model,
        contracted_services,
        record_uuid,
        last_payment_date,
        credit_limit,
        data_usage_current_month,
        latitude,
        longitude,
        credit_score,
        ingestion_timestamp,
        payment_history,
        transformation_timestamp,  
        case
            when lower(trim(city)) in ('barranquilla', 'medellin', 'bogota','cali') then 'colombia'
            when lower(trim(city)) in ('rosario', 'cordoba', 'buenos aires') then 'argentina'
            when lower(trim(city)) in ('santiago', 'valparaiso','concepcion') then 'chile'
            when lower(trim(city)) in ('ciudad de mexico', 'guadalajara') then 'mexico'
            when lower(trim(city)) in ('lima', 'arequipa','trujillo') then 'peru'
            when trim(city) = '' or city is null then null
            else lower(trim(country))
        end as country
    from cleaned
),

fingerprinted as (
    select *,
        -- Fingerprint: clave para identificar registros iguales
        lower(trim(coalesce(first_name, ''))) || '_' ||
        lower(trim(coalesce(last_name, ''))) || '_' ||
        lower(trim(coalesce(email, ''))) || '_' ||
        lower(trim(coalesce(operator, ''))) || '_' ||
        lower(trim(coalesce(country, ''))) as fingerprint
    from country_correction
),

with_ids as (
    select *,
        dense_rank() over (order by fingerprint) as customer_clean_id
    from fingerprinted
),

deduplicated as (
    select distinct on (customer_clean_id) *
    from with_ids
    order by customer_clean_id, ingestion_timestamp desc
)

select 
    customer_clean_id,
    customer_id as original_customer_id,
    first_name,
    last_name,
    email,
    phone_number,
    age,
    country,
    city,
    operator,
    plan_type,
    monthly_data_gb,
    monthly_bill_usd,
    registration_date,
    status,
    device_brand,
    device_model,
    contracted_services,
    record_uuid,
    last_payment_date,
    credit_limit,
    data_usage_current_month,
    latitude,
    longitude,
    credit_score,
    ingestion_timestamp,
    payment_history,
    transformation_timestamp
from deduplicated

