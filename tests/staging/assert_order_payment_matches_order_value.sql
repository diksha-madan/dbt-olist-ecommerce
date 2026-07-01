with payments as(
    select order_id,
    sum(payment_value) as total_payment
    from {{ref('stg_payments')}}
    group by 1
),

order as(
    select order_id,
    sum(price + freight_value) as total_order_value
    from {{ref('stg_orders_items')}}
    group by 1
)

select 
p.order_id,
p.total_payment,
o.total_order_value
from payments p join order o
on p.order_id = o.order_id
where abs(p.total_payment - i.total_order_value) > 0.01