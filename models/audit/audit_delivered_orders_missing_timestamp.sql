select *
from `olist`.`dev_olist_silver`.`int_orders_enriched`
where order_status = 'delivered'
and order_delivered_customer_date_updated is null