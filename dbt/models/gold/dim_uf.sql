{{ config(location='../data/gold/dim_uf.parquet') }}

select
    {{ dbt_utils.generate_surrogate_key(['uf']) }} as uf_sk,
    uf
from {{ ref('stg_uf') }}