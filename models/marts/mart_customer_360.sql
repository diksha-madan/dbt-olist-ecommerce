with customers as (

    select *
    from {{ ref('dim_customers') }}

),

orders as (

    select *
    from {{ ref('fact_orders') }}

),

customer_metrics as (

    select

        customer_id,

        count(distinct order_id) as total_orders,

        sum(total_payment_value) as total_revenue,

        avg(total_payment_value) as avg_order_value,

        avg(avg_review_score) as avg_review_score,

        min(cast(order_purchase_timestamp_updated as date)) as first_order_date,

        max(cast(order_purchase_timestamp_updated as date)) as last_order_date,

        datediff(
            max(cast(order_purchase_timestamp_updated as date)),
            min(cast(order_purchase_timestamp_updated as date))
        ) as customer_lifespan_days,
        max(record_updated_at) as record_updated_at
    from orders

    group by 1

),

final as (

    select

        c.*,

        coalesce(m.total_orders, 0) as total_orders,
        coalesce(m.total_revenue, 0) as total_revenue,
        coalesce(m.avg_order_value, 0) as avg_order_value,
        m.avg_review_score,
        m.first_order_date,
        m.last_order_date,
        m.customer_lifespan_days,

        case
            when m.total_orders = 1
            then true
            else false
        end as is_one_time_customer,

        case
            when m.total_orders > 1
            then true
            else false
        end as is_repeat_customer,

       case
    when coalesce(m.total_orders,0) = 0
    then 'No Orders'

    when m.total_orders = 1
    then 'One-Time'

    when m.customer_lifespan_days <= 30
    then 'New Repeat'

    when m.customer_lifespan_days <= 180
    then 'Established'

    else 'Loyal'
end as customer_segment

    from customers c

    left join customer_metrics m
        on c.customer_id = m.customer_id

)

select *
from final