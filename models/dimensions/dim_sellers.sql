{{
    config(
        materialized='incremental',
        unique_key='seller_id',
        incremental_strategy = 'merge'
    )
}}


select
    seller_id,
    seller_city,
    seller_state,
    seller_zip_code,
    record_updated_at
from {{ref('stg_sellers')}}
{{cdc_filter_merge()}}