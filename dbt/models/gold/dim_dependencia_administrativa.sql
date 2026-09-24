{{ config(location='../data/gold/dim_dependencia_administrativa.parquet') }}

select
    {{ dbt_utils.generate_surrogate_key(['dependencia_administrativa']) }} as dependencia_administrativa_sk,
    dependencia_administrativa
from {{ ref('stg_dependencia_administrativa') }}
