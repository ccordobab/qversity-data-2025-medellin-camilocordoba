{{ config(materialized='table') }}

--What percentage of customers are active/suspended/inactive?

with total as (
    select count(*) as total_customers
    from {{ ref('silver_customers') }}
),

status_counts as (
    select
        lower(status) as status,
        count(*) as count
    from {{ ref('silver_customers') }}
    group by lower(status)
)

select
    s.status,
    s.count,
    round(100.0 * s.count / nullif(t.total_customers, 0), 2) as percentage,
    current_timestamp as report_generated_at
from status_counts s, total t
order by s.count desc
