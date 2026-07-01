{% snapshot order_snapshot %}

{{ 
    config(
        schema = 'snapshots',
        unique_key = 'order_id',
        strategy = 'timestamp',
        updated_at = 'record_updated_at'   
        )
}}

select * from {{ref("stg_orders")}}

{% endsnapshot %}