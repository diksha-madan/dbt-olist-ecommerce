{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy = 'merge'
    )
}}

select 
    order_id,
    customer_id,
    order_purchase_timestamp_updated,
    order_status,

    total_payment_value,
    payment_count,

    avg_review_score,
    total_reviews_count,

    delivery_days,
    is_delayed,
    is_missing_delivery_timestamp,
    record_updated_at

from {{ref('int_orders_enriched')}}
{{cdc_filter_merge()}}