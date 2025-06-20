{{ config(materialized='table') }}

select
    customer_clean_id,
    monthly_data_gb,
    monthly_bill_usd,
    last_payment_date,
    credit_limit,
    data_usage_current_month,
    plan_type
from {{ ref('silver_staging_mobile_customers') }}
