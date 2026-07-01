{% macro cdc_filter_insert_overwrite(column_name='record_updated_at')%}

{% if is_incremental()%}

where {{column_name}} >=
          current_timestamp() - interval 3 days

{% endif %}

{% endmacro %}