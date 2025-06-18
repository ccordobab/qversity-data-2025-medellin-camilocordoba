select
    customer_id,
    first_name,
    last_name,
    email,
    phone_number,
    age,
    country,
    city,
    operator,
    plan_type,
    registration_date,
    status,
    credit_score
from {{ ref('staging_mobile_customers') }}
