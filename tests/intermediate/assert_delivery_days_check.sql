select *
from {{ ref('int_orders_enriched') }}
where delivery_days < 0