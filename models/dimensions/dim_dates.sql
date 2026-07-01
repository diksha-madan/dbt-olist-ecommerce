with date_spine as (

    {{
        dbt_utils.date_spine(
            datepart = "day",
            start_date = "cast('2017-01-01' as date)",
            end_date = "cast('2027-12-31' as date)"
        )
    }}

),

final as (

    select

        cast(date_day as date) as date_day,

        year(date_day) as year,

        quarter(date_day) as quarter,

        month(date_day) as month,

        monthname(date_day) as month_name,

        concat(
            year(date_day),
            '-Q',
            quarter(date_day)
        ) as year_quarter,

        weekofyear(date_day) as week_of_year,

        day(date_day) as day_of_month,

        dayofweek(date_day) as day_of_week,

        date_format(date_day, 'EEEE') as day_name,

        case
            when dayofweek(date_day) in (1, 7)
            then true
            else false
        end as is_weekend,

        case
            when month(date_day) in (1, 2, 3)
            then 'Q1'
            when month(date_day) in (4, 5, 6)
            then 'Q2'
            when month(date_day) in (7, 8, 9)
            then 'Q3'
            else 'Q4'
        end as quarter_name

    from date_spine

)

select *
from final