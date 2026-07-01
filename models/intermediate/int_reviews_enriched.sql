{{
    config(
        materialized = 'incremental',
        incremental_strategy='insert_overwrite',
        partition_by=['partition_date']
    )
}}


with reviews as (

    select * from {{ ref('stg_reviews') }}
    {{cdc_filter_insert_overwrite()}}

),

deduplicated as(
    select * from
    (
        select *, row_number() over (partition by review_id order by record_updated_at desc) as rn 
        from reviews
    )
    where rn=1
),


orders as (

    select
        order_id,
        order_purchase_timestamp_updated,
        order_delivered_customer_date_updated
    from {{ ref('stg_orders') }}

),

final as (

    select

        r.review_id,
        r.order_id,
        r.review_score,
        r.review_comment_title,
        r.review_comment_message,
        r.review_creation_date_updated,
        r.review_answer_timestamp_updated,
        r.record_updated_at,
        cast(r.record_updated_at as date) as partition_date,
        datediff(
            r.review_creation_date_updated,
            o.order_delivered_customer_date_updated
        ) as days_to_review,

        datediff(
            r.review_answer_timestamp_updated,
            r.review_creation_date_updated
        ) as days_to_answer

    from deduplicated r

    left join orders o
        on r.order_id = o.order_id

)

select * from final