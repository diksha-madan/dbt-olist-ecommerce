select *
from {{ ref('int_orders_enriched') }}
where is_delayed = true
and order_delivered_customer_date_updated <= order_estimated_delivery_date_updated