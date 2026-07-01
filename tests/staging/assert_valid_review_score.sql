select * 
from {{ref('stg_reviews')}}
where review_score not between 1 and 5