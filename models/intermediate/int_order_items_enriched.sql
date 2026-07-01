{{
    config(
        materialized='incremental',
        incremental_strategy='insert_overwrite',
        partition_by = ['partition_date']
    )
}}


with order_items as(
    select * from {{ref('stg_order_items')}}
    {{cdc_filter_insert_overwrite()}}
),

deduplicated as(
    select * from
    (
        select *, row_number() over (partition by order_id, order_item_id order by record_updated_at desc) as rn 
        from order_items
    )
    where rn=1
),


products as(
    select * from {{ref('stg_products')}}
),

sellers as(
    select * from {{ref('stg_sellers')}}
),

final as (
    select 
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    p.product_category_name,
    p.product_photos_qty,
    s.seller_city,
    s.seller_state,
    oi.shipping_limit_date_updated,
    oi.price,
    oi.freight_value,
    oi.record_updated_at,
    cast(oi.record_updated_at as date) as partition_date,
    oi.price + oi.freight_value as total_item_value,
    p.product_weight_gm,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,

    p.product_length_cm
    * p.product_height_cm
    * p.product_width_cm as product_volume_cm3

    from deduplicated oi

    left join products p
        on oi.product_id = p.product_id

    left join sellers s
        on oi.seller_id = s.seller_id
    
    
)

select * from final
