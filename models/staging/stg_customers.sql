{{
    config(
        materialized = 'incremental',
        unique_key = 'customer_id',
        incremental_strategy = 'merge'
    )
}}

with source as(
    select * from {{source('raw', 'customers')}}
    {{cdc_filter_merge()}}
),

renamed as(
    select
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix as customer_zip_code,
    customer_city,
    customer_state,
    record_updated_at
    from source
)

select * from renamed