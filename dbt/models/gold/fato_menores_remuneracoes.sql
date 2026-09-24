{{ config(location='../data/gold/fato_menores_remuneracoes.parquet') }}

WITH base AS (
    SELECT * 
    FROM {{ ref('stg_remuneracao_media_docentes') }}
),

remuneracao AS (
    SELECT 
        ano,
        uf, 
        dependencia_administrativa, 
        AVG(valor) AS valor
    FROM base
    GROUP BY ano, uf, dependencia_administrativa

    UNION ALL

    SELECT 
        ano,
        uf, 
        'TODAS' AS dependencia_administrativa, 
        AVG(valor) AS valor
    FROM base
    GROUP BY ano, uf
),

ranking_menores AS (
    SELECT 
        ano,
        uf,
        ROW_NUMBER() OVER (PARTITION BY ano ORDER BY AVG(valor) ASC) AS posicao
    FROM base
    GROUP BY ano, uf
)

SELECT 
    {{ dbt_utils.generate_surrogate_key(['r.uf']) }} AS uf_sk,
    {{ dbt_utils.generate_surrogate_key(['r.ano']) }} AS tempo_sk,
    dim_tempo.ano,
    dim_uf.uf,
    dim_dependencia_administrativa.dependencia_administrativa,
    ROUND(r.valor, 2) AS valor
FROM remuneracao r
JOIN ranking_menores rnk 
    ON r.ano = rnk.ano 
   AND r.uf = rnk.uf
LEFT JOIN {{ ref('stg_uf') }} dim_uf
    ON r.uf = dim_uf.uf
LEFT JOIN {{ ref('stg_tempo') }} dim_tempo
    ON r.ano = dim_tempo.ano
LEFT JOIN {{ ref('stg_dependencia_administrativa') }} dim_dependencia_administrativa
    ON r.dependencia_administrativa = dim_dependencia_administrativa.dependencia_administrativa
WHERE rnk.posicao <= 5
ORDER BY 
    r.ano ASC,
    rnk.posicao ASC,
    CASE WHEN r.dependencia_administrativa = 'TODAS' THEN 1 ELSE 0 END,
    r.dependencia_administrativa ASC