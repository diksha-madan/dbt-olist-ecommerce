with products as (

    select * from {{ ref('dim_products') }}

),

sales as (

    select

        product_id,

        count(*) as total_items_sold,

        sum(total_item_value) as total_revenue,

        avg(price) as avg_price

    from {{ ref('fact_order_items') }}

    group by 1

)

select

    p.*,

    coalesce(s.total_items_sold,0) as total_items_sold,

    coalesce(s.total_revenue,0) as total_revenue,

    s.avg_price,

    case
        when s.product_id is null
        then false
        else true
    end as is_sold

from products p

left join sales s
    on p.product_id = s.product_id