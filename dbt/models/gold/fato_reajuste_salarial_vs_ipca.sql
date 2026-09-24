{{ config(location='../data/gold/fato_reajuste_salarial_vs_ipca.parquet') }}

WITH remuneracao_ano AS (
    SELECT 
        ano,
        uf,
        AVG(valor) valor
    FROM {{ ref('stg_remuneracao_media_docentes') }}
    GROUP BY ano, uf
),

variacao_salarial AS (
    SELECT 
        ano,
        uf,
        valor AS valor_atual,
        LAG(valor) OVER (PARTITION BY uf ORDER BY ano ASC) AS valor_ano_anterior,
        ROUND(
            ((valor - LAG(valor) OVER (PARTITION BY uf ORDER BY ano ASC)) 
            / NULLIF(LAG(valor) OVER (PARTITION BY uf ORDER BY ano ASC), 0)) * 100, 
            2
        ) AS variacao_salarial_pct
    FROM remuneracao_ano
)

SELECT 
    {{ dbt_utils.generate_surrogate_key(['v.ano']) }} AS tempo_sk,
    {{ dbt_utils.generate_surrogate_key(['v.uf']) }} AS uf_sk,
    dim_tempo.ano,
    dim_uf.uf,
    ROUND(v.valor_atual, 2) AS valor_atual,
    ROUND(v.valor_ano_anterior, 2) AS valor_ano_anterior,
    ROUND(v.valor_atual - v.valor_ano_anterior, 2) AS variacao_salarial,
    v.variacao_salarial_pct,
    ipca.valor AS ipca,
    ROUND(v.variacao_salarial_pct - ipca.valor, 2) AS ganho_real,
    CASE 
        WHEN v.variacao_salarial_pct >= ipca.valor THEN 'POSITIVO'
        ELSE 'NEGATIVO'
    END AS desempenho
FROM variacao_salarial v
LEFT JOIN {{ ref('stg_ipca') }} ipca
    ON v.ano = ipca.ano
LEFT JOIN {{ ref('stg_uf') }} dim_uf
    ON v.uf = dim_uf.uf
LEFT JOIN {{ ref('stg_tempo') }} dim_tempo
    ON v.ano = dim_tempo.ano
WHERE v.ano > 2014
ORDER BY 
    v.uf ASC,
    v.ano ASC