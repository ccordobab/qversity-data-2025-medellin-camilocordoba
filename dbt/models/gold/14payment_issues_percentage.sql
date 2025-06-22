{{ config(materialized='table') }}

-- What percentage of customers have payment issues?

with all_customers as (
    select distinct customer_id
    from {{ ref('silver_customers') }}
),


issues as (
    select distinct customer_id
    from {{ ref('silver_payment_history') }}
    where trim(lower(status)) not in ('paid', 'completed', 'success')
),


counts as (
    select
        (select count(*) from all_customers) as total_customers,
        (select count(*) from issues) as customers_with_issues
)

select
    total_customers,
    customers_with_issues,
    100.0 * customers_with_issues / nullif(total_customers, 0) as percentage_with_issues,
    current_timestamp as report_generated_at
from counts
