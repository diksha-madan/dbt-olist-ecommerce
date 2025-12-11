with source as(
    select * from {{source('raw', 'olist_order_items_dataset')}}
),

renamed as(
    select
    order_id,
    order_item_id,
    product_id,
    seller_id,
    {{ parse_timestamp('shipping_limit_date') }} as shipping_limit_ts,
    cast(price as double) as price,
    cast(freight_value as double) as freight_value
    from source
)

select * from renamed