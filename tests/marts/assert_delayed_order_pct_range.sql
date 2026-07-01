select *
from {{ ref('mart_revenue') }}
where delayed_order_pct < 0
or delayed_order_pct > 100