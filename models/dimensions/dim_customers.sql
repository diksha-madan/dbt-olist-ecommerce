-- models/test_cdc.sql

{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='customer_id'
    )
}}

select
    customer_id,
    customer_unique_id,
    customer_city,
    customer_state,
    customer_zip_code,
    record_updated_at

from {{ ref('stg_customers') }}
{{cdc_filter_merge()}}