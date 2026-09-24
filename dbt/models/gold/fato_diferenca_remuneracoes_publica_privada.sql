{{ config(location='../data/gold/fato_diferenca_remuneracoes_publica_privada.parquet') }}

WITH base AS (
    SELECT * 
    FROM {{ ref('stg_remuneracao_media_docentes') }}
),

remuneracao_pivotada AS (
    SELECT 
        ano,
        uf,
        MAX(CASE WHEN UPPER(dependencia_administrativa) = 'PRIVADA' THEN valor END) AS valor_privada,
        MAX(CASE WHEN UPPER(dependencia_administrativa) = 'PUBLICA' THEN valor END) AS valor_publica
    FROM base
    GROUP BY ano, uf
)

SELECT 
    dim_tempo.tempo_sk,
    dim_uf.uf_sk,
    dim_tempo.ano,
    dim_uf.uf,
    rp.valor_privada AS valor_privada,
    rp.valor_publica AS valor_publica,
    rp.valor_privada - rp.valor_publica AS dif_absoluta_privada_publica,
    ROUND(((rp.valor_privada - rp.valor_publica) / NULLIF(rp.valor_publica, 0)) * 100, 2) AS dif_percentual
FROM remuneracao_pivotada rp
LEFT JOIN {{ ref('dim_uf') }} dim_uf
    ON rp.uf = dim_uf.uf
LEFT JOIN {{ ref('dim_tempo') }} dim_tempo
    ON rp.ano = dim_tempo.ano
ORDER BY 
    dim_tempo.ano ASC,
    dim_uf.uf ASC