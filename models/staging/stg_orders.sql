with source as(
    select * from {{source('raw', 'olist_orders_dataset')}}
),

renamed as(
    select 
    order_id,
    customer_id,
    order_status,
    {{parse_timestamp('order_purchase_timestamp')}} as order_purchase_ts,
    {{parse_timestamp('order_approved_at')}} as order_approved_ts,
    {{parse_timestamp('order_delivered_customer_date')}} as delivered_customer_ts,
    {{parse_timestamp('order_estimated_delivery_date')}} as estimated_delivery_ts
    from source
)

select * from renamed