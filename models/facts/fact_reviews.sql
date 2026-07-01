{{
    config(
        materialized='incremental',
        incremental_strategy = 'insert_overwrite',
        partition_by = ['partition_date']
    )
}}

select 
    review_id,
    order_id,

    review_score,

    review_comment_title,
    review_comment_message,

    review_creation_date_updated,
    review_answer_timestamp_updated,
    record_updated_at,
    days_to_answer,
    days_to_review,
    cast(record_updated_at as date) as partition_date
from {{ref('int_reviews_enriched')}}
{{cdc_filter_insert_overwrite()}}