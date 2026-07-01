with orders as (

    select *
    from {{ ref('fact_orders') }}

),

daily_metrics as (

    select

        cast(order_purchase_timestamp_updated as date) as order_date,

        count(distinct order_id) as total_orders,

        count(distinct customer_id) as total_customers,

        sum(total_payment_value) as revenue,

        avg(total_payment_value) as average_order_value,

        avg(avg_review_score) as average_review_score,

        avg(delivery_days) as average_delivery_days,

        sum(
            case
                when is_delayed = true then 1
                else 0
            end
        ) as delayed_orders

    from orders

    group by 1

),

final as (

    select

        order_date,

        total_orders,

        total_customers,

        revenue,

        average_order_value,

        average_review_score,

        average_delivery_days,

        delayed_orders,

        round(
            delayed_orders * 100.0 / total_orders,
            2
        ) as delayed_order_pct

    from daily_metrics

)

select *
from final