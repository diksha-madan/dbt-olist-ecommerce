{{
    config(
        materialized='incremental',
        incremental_strategy='insert_overwrite',
        partition_by = ['partition_date']
    )
}}


with source as(
    select * from {{source('raw', 'reviews')}}
     {{cdc_filter_insert_overwrite()}}
),

deduplicated as(
    select * from 
    (
        select *, row_number() over (partition by review_id order by record_updated_at desc) as rn
        from source
    )
    where rn=1
),


renamed as(
    select
    review_id,
    order_id,
    case 
        when review_score rlike '^[1-5]$'
        then cast(review_score as int)
        else null
    end
     as review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date_updated,
    review_answer_timestamp_updated,
    record_updated_at,
    cast(record_updated_at as date) as partition_date
    from deduplicated

   
)

select * from renamed