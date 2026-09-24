{{ config(location='../data/silver/stg_remuneracao_media_docentes.parquet') }}

select
    try_cast(ano as integer) as ano,
    upper(trim(uf)) as uf,
    upper(strip_accents(trim(dependencia_administrativa))) as dependencia_administrativa,
    cast(round(cast(valor as double), 2) as decimal(18, 2)) as valor
from {{ source('bronze', 'remuneracao-media-docentes') }}
