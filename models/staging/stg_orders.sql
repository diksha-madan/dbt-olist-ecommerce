{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy = 'merge'
    )
}}


with source as(
    select * from {{source('raw', 'orders')}}
     {{cdc_filter_merge()}}
),

renamed as(
    select 
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp_updated,
    order_approved_at_updated,
    order_delivered_customer_date_updated,
    order_estimated_delivery_date_updated,
    record_updated_at
    from source

   

)

select * from renamed