
{% macro cdc_filter_merge(column_name='record_updated_at', lookback_days = 5) %}

{% if is_incremental() %}

where {{ column_name }} 
        >= current_timestamp() - interval {{ lookback_days }} days
   

{% endif %}

{% endmacro %}