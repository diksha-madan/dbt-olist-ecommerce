select *
from {{ref('stg_orders')}}
where order_estimated_delivery_date_updated < order_purchase_timestamp_updated