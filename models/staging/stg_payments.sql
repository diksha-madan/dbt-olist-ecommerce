{{
    config(
        materialized='incremental',
        incremental_strategy = 'insert_overwrite',
        partition_by=['partition_date']
    )
}}


with source as(
    select * from {{source('raw', 'payments')}}
    
    {{cdc_filter_insert_overwrite()}}
),

deduplicated as(
    select * from
    (
        select *, row_number() over (partition by order_id, payment_sequential order by record_updated_at desc) as rn 
        from source
    )
    where rn=1
),

renamed as(
    select
    order_id,
    payment_sequential,
    lower(payment_type) as payment_type,
    cast(payment_installments as int) as payment_installments,
    cast(payment_value as double) as payment_value,
    record_updated_at,
    cast(record_updated_at as date) as partition_date
    from deduplicated
)

select * from renamed