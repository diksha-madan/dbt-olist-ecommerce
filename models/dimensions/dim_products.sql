{{
    config(
        materialized='incremental',
        unique_key='product_id',
        incremental_strategy = 'merge'
    )
}}


select 
    product_id,
    product_category_name,
    product_photos_qty,
    product_weight_gm,
    product_length_cm,
    product_height_cm,
    product_width_cm,
    record_updated_at
from {{ref('stg_products')}}
{{cdc_filter_merge()}}