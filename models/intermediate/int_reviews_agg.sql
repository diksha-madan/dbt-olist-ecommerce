with reviews as(
    select * from {{ref('int_reviews_enriched')}}
),

aggregated as(
    select 
    order_id,
    count(distinct review_id) as total_reviews_count,
    avg(review_score) as avg_review_score,
    max(record_updated_at) as record_updated_at,
        max(partition_date) as partition_date
    from reviews
    group by 1
)

select * from aggregated