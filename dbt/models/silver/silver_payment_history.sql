{{ config(materialized='table') }}

with filtered as (

    select
        customer_clean_id,
        payment_history
    from {{ ref('silver_staging_mobile_customers') }}
    where 
        payment_history ~ '^\[.*\]$' -- solo valores que parecen listas JSON

),

casted as (

    select
        customer_clean_id,
        payment_history::jsonb as payment_json
    from filtered

),

exploded as (

    select
        customer_clean_id,
        jsonb_array_elements(payment_json) as payment_entry
    from casted

),

final as (

    select
        customer_clean_id,
        cast(payment_entry ->> 'date' as date) as date,
        payment_entry ->> 'status' as status,
        cast(nullif(payment_entry ->> 'amount', '') as numeric) as amount,
        current_timestamp as created_at
    from exploded
    where 
        payment_entry ? 'date'
        and payment_entry ? 'status'
        and payment_entry ? 'amount'
        and (payment_entry ->> 'amount') ~ '^[0-9.]+$'

)

select * from final



