{{ config(location='../data/silver/stg_uf.parquet') }}

select distinct
    upper(trim(uf)) as uf
from {{ source('bronze', 'remuneracao-media-docentes') }}
where uf is not null
