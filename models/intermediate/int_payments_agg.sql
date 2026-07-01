
with payments as(
    select * from {{ref('int_payments_enriched')}}
),

aggregated as(
    select 
    order_id, 
    sum(payment_value) as total_payment_value,
    max(payment_installments) as max_payment_installments,
    count(*) as payment_count,
    count(distinct payment_type) as payment_type_count,
    max(record_updated_at) as record_updated_at,
        max(partition_date) as partition_date,
    max(
                case
                    when is_installment_payment then 1
                    else 0
                end
            ) as has_installments
    from payments
    group by 1
)

select * from aggregated