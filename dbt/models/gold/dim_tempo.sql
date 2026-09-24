{{ config(location='../data/gold/dim_tempo.parquet') }}

select
    {{ dbt_utils.generate_surrogate_key(['ano']) }} as tempo_sk,
    ano
from {{ ref('stg_tempo') }}
