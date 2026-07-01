{{
    config(
        materialized='incremental',
        unique_key='seller_id',
        incremental_strategy = 'merge'
    )
}}


with source as(
    select * from {{source('raw', 'sellers')}}
    {{cdc_filter_merge()}}
),

renamed as(
    select
    seller_id,
    seller_zip_code_prefix as seller_zip_code,
    seller_city,
    seller_state,
    record_updated_at
    from source
)

select * from renamed