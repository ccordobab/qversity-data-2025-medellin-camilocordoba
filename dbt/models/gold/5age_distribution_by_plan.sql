{{ config(materialized='table') }}

select
    c.age,
    p.plan_type,
    count(*) as customer_count
from {{ ref('silver_customers') }} as c
join {{ ref('silver_plans') }} as p on c.customer_clean_id = p.customer_clean_id
group by c.age, p.plan_type
order by p.plan_type, c.age desc
