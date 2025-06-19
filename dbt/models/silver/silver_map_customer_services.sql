{{ config(materialized='table') }}

-- Paso 1: Explotar y limpiar servicios
with exploded as (
    select
        c.customer_clean_id,
        s.service_id
    from {{ ref('silver_staging_mobile_customers') }} c,
    lateral unnest(
        string_to_array(
            regexp_replace(
                regexp_replace(lower(trim(contracted_services)), '[{}]', '', 'g'),
                '\s+', '', 'g'
            ),
            ','
        )
    ) as service_name
    inner join {{ ref('silver_services') }} s
        on s.service = service_name
    where contracted_services is not null
),

-- Paso 2: Agrupar y limpiar combinaciones
grouped_services as (
    select
        customer_clean_id,
        array_agg(distinct service_id order by service_id) as service_ids,
        array_to_string(array_agg(distinct service_id order by service_id), ',') as service_ids_str
    from exploded
    group by customer_clean_id
),

-- Paso 3: Obtener combinaciones únicas
distinct_service_combinations as (
    select distinct service_ids_str
    from grouped_services
),

-- Paso 4: Asignar un ID a cada combinación única
with_group_ids as (
    select
        row_number() over (order by service_ids_str) as service_group_id,
        service_ids_str
    from distinct_service_combinations
),

-- Paso 5: Asociar cada cliente con su grupo
final as (
    select
        g.customer_clean_id,
        wg.service_group_id,
        g.service_ids_str  -- para validación visual
    from grouped_services g
    join with_group_ids wg
        on g.service_ids_str = wg.service_ids_str
)

-- Resultado final con clave de validación visible
select 
    customer_clean_id,
    service_group_id,
    service_ids_str  -- ¡esto te deja ver si dos clientes con el mismo ID realmente tienen lo mismo!
from final
order by service_group_id, customer_clean_id

