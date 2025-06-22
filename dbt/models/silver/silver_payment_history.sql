{{ config(materialized='table') }}

-- Filter rows that contain a valid-looking payment_history

with filtered as (

    select
        customer_id,
        -- Replace all single quotes with double quotes to convert to valid JSON
        replace(payment_history, '''', '"') as payment_history
    from {{ ref('silver_staging_mobile_customers') }}
    -- Regex to ensure we only keep rows where payment_history looks like a list: starts and ends with brackets []
    where 
        payment_history ~ '^\[.*\]$'

),

--  Cast the cleaned strings into JSONB arrays for further processing
casted as (

    select
        customer_id,
        -- Cast the fixed JSON string to a JSONB object (PostgreSQL's binary JSON format)
        payment_history::jsonb as payment_json
    from filtered

),

-- Explode JSON array so each element becomes one row (per payment)
exploded as (

    select
        customer_id,
        -- Decompose each element in the JSON array into individual rows
        -- jsonb_array_elements() iterates over the array elements
        jsonb_array_elements(payment_json) as payment_entry
    from casted

),

-- Extract values from each payment object
final as (

    select
        customer_id,
        -- Extract 'date' field from JSON, cast to SQL DATE
        cast(payment_entry ->> 'date' as date) as date,
        payment_entry ->> 'status' as status,
        -- Extract 'amount' and cast to numeric (after ensuring it's not an empty string)
        cast(nullif(payment_entry ->> 'amount', '') as numeric) as amount,
        current_timestamp as processed_at
    from exploded
    -- Ensure the JSON entry has all expected fields
    where 
        payment_entry ? 'date'
        and payment_entry ? 'status'
        and payment_entry ? 'amount'
        -- Ensure the 'amount' field contains only numbers and decimals (no letters)
        and (payment_entry ->> 'amount') ~ '^[0-9.]+$'

)

select * from final



