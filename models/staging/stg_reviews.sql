with source as(
    select * from {{source('raw', 'olist_order_reviews_dataset')}}
),

valid_orders as(
    select order_id
    from {{ref('stg_orders')}}
),

renamed as(
    select
    review_id,
    source.order_id,
    case 
        when review_score rlike '^[1-5]$'
        then cast(review_score as int)
        else null
    end
     as review_score,
    review_comment_title,
    review_comment_message,
    {{parse_timestamp('review_creation_date')}} as review_creation_ts,
    {{parse_timestamp('review_answer_timestamp')}} as review_answer_ts
    from source
    join valid_orders
    on source.order_id = valid_orders.order_id
    WHERE review_id is NOT NULL
)

select * from renamed