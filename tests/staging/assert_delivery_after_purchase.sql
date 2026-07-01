select * 
from {{ref('stg_orders')}}
where order_delivered_customer_date_updated < order_purchase_timestamp_updated