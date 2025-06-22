{{ config(materialized='table') }}

-- How does credit score correlate with payment behavior?

with payments as (
    select
        customer_id,
        status
    from {{ ref('silver_payment_history') }}
),

failed_payments as (
    select
        customer_id,
        count(*) as failed_count
    from payments
    where lower(status) not in ('paid', 'completed', 'success')
    group by customer_id
),

total_payments as (
    select
        customer_id,
        count(*) as total_count
    from payments
    group by customer_id
),

credit_scores as (
    select
        customer_id,
        credit_score
    from {{ ref('silver_customers') }}
    where credit_score is not null
),

joined as (
    select
        c.customer_id,
        c.credit_score,
        coalesce(f.failed_count, 0) as failed_payments,
        t.total_count,
        round(100.0 * coalesce(f.failed_count, 0) / nullif(t.total_count, 0), 2) as failure_rate
    from credit_scores c
    left join failed_payments f on c.customer_id = f.customer_id
    join total_payments t on c.customer_id = t.customer_id
)

select
    case
        when credit_score < 400 then 'Low'
        when credit_score < 650 then 'Medium'
        when credit_score < 850 then 'High'
        else 'Unknown'
    end as credit_segment,
    avg(failure_rate) as avg_failure_rate,
    count(*) as customer_count,
    current_timestamp as report_generated_at
from joined
group by credit_segment
order by avg_failure_rate desc
