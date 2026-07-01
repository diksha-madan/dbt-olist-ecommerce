select *
from {{ ref('mart_revenue') }}
where average_order_value < 0