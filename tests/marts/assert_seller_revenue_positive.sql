select *
from {{ ref('mart_seller_performance') }}
where total_revenue < 0