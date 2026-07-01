select *
from {{ ref('int_payments_enriched') }}
where payment_value < 0