{{
    config(
        materialized = "incremental",
        incremental_strategy = 'merge',
        unique_key = 'order_id'
    )
}}

with orders as(
    select * from {{ref('stg_orders')}}
    {{cdc_filter_merge()}}
),

payments as (
    select * from {{ref('int_payments_agg')}}
),

reviews as(
    select * from {{ref('int_reviews_agg')}}
),

final as(
    select
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp_updated,
    order_delivered_customer_date_updated,
    order_estimated_delivery_date_updated,
    o.record_updated_at,
    p.total_payment_value,
    p.payment_count,
    r.avg_review_score,
    r.total_reviews_count,

    datediff(
        o.order_delivered_customer_date_updated,
        o.order_purchase_timestamp_updated
    ) as delivery_days,

    case
            when o.order_delivered_customer_date_updated >
                 o.order_estimated_delivery_date_updated
            then true
            else false
        end as is_delayed,

        case
    when order_status = 'delivered'
         and order_delivered_customer_date_updated is null
    then true
    else false
end as is_missing_delivery_timestamp

from orders o
left join payments p on o.order_id = p.order_id
left join reviews r on o.order_id = r.order_id


    
)

select * from final