with source as (
    select * 
    from {{ ref('bronze_raw_mobile_customers') }}
),

cleaned as (
    select 
        customer_id,
        initcap(trim(first_name)) as first_name,
        initcap(trim(last_name)) as last_name,
        lower(trim(email)) as email,
        trim(phone_number) as phone_number,
        cast(age as integer) as age,

        case lower(trim(country))
            when 'peru' then 'peru'
            when 'pe' then 'peru'
            when 'pru' then 'peru'
            when 'per' then 'peru'
            when 'argentina' then 'argentina'
            when 'arg' then 'argentina'
            when 'argentna' then 'argentina'
            when 'argentin' then 'argentina'
            when 'ar' then 'argentina'
            when 'mexico' then 'mexico'
            when 'mx' then 'mexico'
            when 'mejico' then 'mexico'
            when 'mex' then 'mexico'
            when 'mexco' then 'mexico'
            when 'colombia' then 'colombia'
            when 'col' then 'colombia'
            when 'colombi' then 'colombia'
            when 'colomia' then 'colombia'
            when 'chl' then 'chile'
            when 'cl' then 'chile'
            when 'chle' then 'chile'
            when 'chi' then 'chile'
            else lower(trim(country))
        end as country,

        case lower(trim(city))
            when 'lima' then 'lima'
            when 'arequipa' then 'arequipa'
            when 'areqipa' then 'arequipa'
            when 'trujillo' then 'trujillo'
            when 'medellin' then 'medellin'
            when 'medelin' then 'medellin'
            when 'cal' then 'cali'
            when 'cali' then 'cali'
            when 'bogota' then 'bogota'
            when 'bogotá' then 'bogota'
            when 'cdmx' then 'ciudad de mexico'
            when 'ciudad de mexico' then 'ciudad de mexico'
            when 'guadalajara' then 'guadalajara'
            when 'guadaljara' then 'guadalajara'
            when 'rosario' then 'rosario'
            when 'santiago' then 'santiago'
            when 'santigo' then 'santiago'
            when 'valparaiso' then 'valparaiso'
            when 'valparaíso' then 'valparaiso'
            when 'concepcion' then 'concepcion'
            when 'concepción' then 'concepcion'
            when 'cordoba' then 'cordoba'
            when 'coroba' then 'cordoba'
            when 'buenos aires' then 'buenos aires'
            when 'barranquilla' then 'barranquilla'
            else lower(trim(city))
        end as city,

        case lower(trim(operator))
            when 'won' then 'wom'
            when 'wom' then 'wom'
            when 'w0m' then 'wom'
            when 'clar' then 'claro'
            when 'claro' then 'claro'
            when 'cla' then 'claro'
            when 'tigo' then 'tigo'
            when 'tgo' then 'tigo'
            when 'tig' then 'tigo'
            when 'movistar' then 'movistar'
            when 'movistr' then 'movistar'
            when 'movi' then 'movistar'
            when 'mov' then 'movistar'
            else lower(trim(operator))
        end as operator,

        case lower(trim(plan_type))
            when 'prepago' then 'prepago'
            when 'pre_pago' then 'prepago'
            when 'pre' then 'prepago'
            when 'pre-pago' then 'prepago'
            when 'post_pago' then 'pospago'
            when 'pospago' then 'pospago'
            when 'pos' then 'pospago'
            when 'pospago' then 'pospago'
            when 'post-pago' then 'pospago'
            when 'control' then 'control'
            when 'ctrl' then 'control'
            when 'contrrol' then 'control'
            else lower(trim(plan_type))
        end as plan_type,

        cast(monthly_data_gb as numeric) as monthly_data_gb,
        cast(monthly_bill_usd as numeric) as monthly_bill_usd,
        to_date(registration_date, 'YYYY-MM-DD') as registration_date,
        lower(trim(status)) as status,

        case
            when lower(trim(status)) in ('active', 'activo', 'válido') then 'activo'
            when lower(trim(status)) in ('inactive', 'inactivo', 'invalid') then 'inactivo'
            when lower(trim(status)) in ('suspended', 'suspendido') then 'suspendido'
            when trim(status) = '' or status is null then null
            else lower(trim(status))
        end as status,

        case lower(trim(device_brand))
            when 'appl' then 'apple'
            when 'aple' then 'apple'
            when 'apple' then 'apple'
            when 'samsung' then 'samsung'
            when 'samsun' then 'samsung'
            when 'samsg' then 'samsung'
            when 'xiaomi' then 'xiaomi'
            when 'xaomi' then 'xiaomi'
            when 'xiami' then 'xiaomi'
            when 'huawei' then 'huawei'
            when 'huwai' then 'huawei'
            when 'hauwei' then 'huawei'
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
)

select * from cleaned;
