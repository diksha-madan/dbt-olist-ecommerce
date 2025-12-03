with source as(
    select * from {{source('raw', 'olist_geolocation_dataset')}}
),

renamed as(
    select 
    geolocation_zip_code_prefix as geolocation_zip_code,
    cast(geolocation_lat as double) as geolocation_lat ,
    cast(geolocation_lng as double) as geolocation_lng,
    lower(geolocation_city) as geolocation_city,
    geolocation_state
    from source
)

select * from renamed