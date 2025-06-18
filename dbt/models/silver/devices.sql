select
    customer_id,
    device_brand,
    device_model,
from {{ ref('staging_mobile_customers') }}
