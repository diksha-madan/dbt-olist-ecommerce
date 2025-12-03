with source as(
    select * from {{source('raw', 'olist_products_dataset')}}
),

renamed as(
    select
    product_id,
    lower(product_category_name),
    product_photos_qty,
    cast(product_weight_g as int) as product_weight_gm,
    cast(product_length_cm as int) as product_length_cm,
    cast(product_height_cm as int) as product_height_cm,
    cast(product_width_cm as int) as product_width_cm

    from source

)

select * from renamed