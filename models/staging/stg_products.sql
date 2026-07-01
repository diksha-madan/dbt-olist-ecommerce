{{
    config(
        materialized='incremental',
        unique_key='product_id',
        incremental_strategy = 'merge'
    )
}}


with source as(
    select * from {{source('raw', 'products')}}
    {{cdc_filter_merge()}}
),

renamed as(
    select
    product_id,
    lower(product_category_name) as product_category_name,
    product_photos_qty,
    cast(product_weight_g as int) as product_weight_gm,
    cast(product_length_cm as int) as product_length_cm,
    cast(product_height_cm as int) as product_height_cm,
    cast(product_width_cm as int) as product_width_cm,
    record_updated_at

    from source
    

)

select * from renamed