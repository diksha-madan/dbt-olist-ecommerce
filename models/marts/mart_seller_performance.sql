with sellers as (

    select *
    from {{ ref('dim_sellers') }}

),

order_items as (

    select *
    from {{ ref('fact_order_items') }}

),

orders as (

    select *
    from {{ ref('fact_orders') }}

),

seller_sales as (

    select

        seller_id,

        count(distinct order_id) as total_orders,

        count(distinct product_id) as distinct_products_sold,

        count(*) as total_items_sold,

        sum(total_item_value) as total_revenue,

        avg(price) as avg_selling_price

    from order_items

    group by 1

),

seller_reviews as (

    select

        oi.seller_id,

        avg(o.avg_review_score) as avg_review_score

    from order_items oi

    inner join orders o
        on oi.order_id = o.order_id

    group by 1

),

final as (

    select

        s.seller_id,
        s.seller_city,
        s.seller_state,
        s.seller_zip_code,

        coalesce(ss.total_orders, 0) as total_orders,

        coalesce(ss.distinct_products_sold, 0)
            as distinct_products_sold,

        coalesce(ss.total_items_sold, 0)
            as total_items_sold,

        coalesce(ss.total_revenue, 0)
            as total_revenue,

        ss.avg_selling_price,

        sr.avg_review_score,

        case
            when ss.seller_id is null then false
            else true
        end as has_sales

    from sellers s

    left join seller_sales ss
        on s.seller_id = ss.seller_id

    left join seller_reviews sr
        on s.seller_id = sr.seller_id

)

select *
from final