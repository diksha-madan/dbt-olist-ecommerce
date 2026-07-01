{{
    config(
        materialized='incremental',
        incremental_strategy = 'insert_overwrite',
        partition_by=['partition_date']
    )
}}


with source as(
    select * from {{source('raw', 'order_items')}}
    {{cdc_filter_insert_overwrite()}}
),

deduplicated as(
    select * from
    (
        select *, row_number() over (partition by order_id, order_item_id order by record_updated_at desc) as rn 
        from source
    )
    where rn=1
),

renamed as(
    select
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date_updated,
    cast(price as double) as price,
    cast(freight_value as double) as freight_value,
    record_updated_at,
    cast(record_updated_at as date) as partition_date
    from deduplicated

)

select * from renamed