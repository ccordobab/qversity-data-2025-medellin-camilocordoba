{{ config(materialized='table') }}
-- What is customer segmentation by credit score ranges?
select
    case
        when credit_score < 400 then 'less than 400'
        when credit_score < 600 then '400-599'
        when credit_score < 750 then '600-749'
        when credit_score < 850 then 'greater than 750'
        else 'Unknown'
    end as credit_segment,
    count(*) as customer_count,
    current_timestamp as report_generated_at
from {{ ref('silver_customers') }}
group by credit_segment
order by customer_count desc
