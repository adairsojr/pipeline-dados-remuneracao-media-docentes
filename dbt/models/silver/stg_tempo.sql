{{ config(location='../data/silver/stg_tempo.parquet') }}

select distinct
    cast(ano as integer) as ano
from {{ source('bronze', 'remuneracao-media-docentes') }}
