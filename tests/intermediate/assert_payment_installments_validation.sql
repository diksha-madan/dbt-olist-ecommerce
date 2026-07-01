select *
from {{ ref('int_payments_enriched') }}
where is_installment_payment = true
  and payment_installments <= 1