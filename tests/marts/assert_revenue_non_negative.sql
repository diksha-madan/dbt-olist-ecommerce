select *
from {{ ref('mart_revenue') }}
where revenue < 0