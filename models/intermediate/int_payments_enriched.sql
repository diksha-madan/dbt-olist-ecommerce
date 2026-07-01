{{
    config(
        materialized = 'incremental',
        incremental_strategy='insert_overwrite',
        partition_by = ['partition_date']
    )
}}

with payments as (
    select *
from {{ ref('stg_payments') }}
{{cdc_filter_insert_overwrite()}}
),

deduplicated as (
    select *,
    row_number() over (partition by order_id, payment_sequential order by record_updated_at desc) as rn 
    from payments
),

final as(
    select
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value,
    case
    when payment_installments > 1 then true
    else false
    end as is_installment_payment,
    record_updated_at,
    cast(record_updated_at as date) as partition_date
    from deduplicated
    where rn=1
)

select * from final
