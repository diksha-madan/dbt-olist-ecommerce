{{
    config(
        materialized='incremental',
        incremental_strategy = 'insert_overwrite',
        partition_by = ['partition_date']
    )
}}

select
order_id,
payment_sequential,

payment_type,
payment_installments,
payment_value,
record_updated_at,
is_installment_payment,
cast(record_updated_at as date) as partition_date

from {{ref('int_payments_enriched')}}
{{cdc_filter_insert_overwrite()}}