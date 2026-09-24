{{ config(location='../data/silver/stg_dependencia_administrativa.parquet') }}

select distinct
    upper(strip_accents(trim(dependencia_administrativa))) as dependencia_administrativa
from {{ source('bronze', 'remuneracao-media-docentes') }}
where dependencia_administrativa is not null
