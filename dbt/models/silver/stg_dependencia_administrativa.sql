{{ config(location='../data/silver/stg_dependencia_administrativa.parquet') }}

with dependencias_administrativas as (
    select distinct
        upper(strip_accents(trim(dependencia_administrativa))) as dependencia_administrativa
    from {{ source('bronze', 'remuneracao-media-docentes') }}
    where dependencia_administrativa is not null
)

select dependencia_administrativa from dependencias_administrativas
union all
select 'TODAS' as dependencia_administrativa
