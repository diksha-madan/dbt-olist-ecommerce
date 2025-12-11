{% macro parse_timestamp(col) %}
(
  coalesce(
    try_to_timestamp(regexp_replace(trim({{ col }}), '\\s+', ' '), 'M/d/yyyy H:mm'),
    try_to_timestamp(regexp_replace(trim({{ col }}), '\\s+', ' '), 'M/d/yyyy H:mm:ss'),
    try_to_timestamp(regexp_replace(trim({{ col }}), '\\s+', ' '), 'M/d/yyyy h:mm:ss a'),
    try_to_timestamp(regexp_replace(trim({{ col }}), '\\s+', ' '), 'M/d/yyyy h:mm a'),
    try_to_timestamp(regexp_replace(trim({{ col }}), '\\s+', ' '), 'MM/dd/yyyy HH:mm'),
    try_to_timestamp(regexp_replace(trim({{ col }}), '\\s+', ' '), 'MM/dd/yyyy HH:mm:ss'),
    try_to_timestamp(regexp_replace(trim({{ col }}), '\\s+', ' '), 'yyyy-MM-dd HH:mm:ss')
  )
)
{% endmacro %}
