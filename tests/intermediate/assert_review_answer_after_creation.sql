select *
from {{ ref('int_reviews_enriched') }}
where review_answer_timestamp_updated < review_creation_date_updated