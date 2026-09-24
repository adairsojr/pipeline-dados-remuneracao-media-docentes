{{ config(location='../data/silver/stg_ipca.parquet') }}

select
    try_cast(ano as integer) as ano,
    cast(round(cast(valor as double), 2) as decimal(18, 2)) as valor
from {{ source('bronze', 'ipca') }}