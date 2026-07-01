{% snapshot product_snapshot%}

{{
    config(
        target_schema = 'snapshots',
        strategy = 'timestamp',
        unique_key = 'product_id',
        updated_at = 'record_updated_at'
    )
}}

select * from {{ref('stg_products')}}

{% endsnapshot %}