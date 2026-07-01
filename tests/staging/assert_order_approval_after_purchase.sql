select *
from {{ref('stg_orders')}}
where order_approved_at_updated < order_purchase_timestamp_updated