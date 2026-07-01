{{
    config(
        materialized='incremental',
        incremental_strategy = 'insert_overwrite',
        partition_by = ['partition_date']
    )
}}

select 

    order_id,
    order_item_id,
    product_id,
    seller_id,

    price,
    freight_value,
    total_item_value,
    record_updated_at,
    shipping_limit_date_updated,
     cast(record_updated_at as date) as partition_date

from {{ref('int_order_items_enriched')}}
{{cdc_filter_insert_overwrite()}}