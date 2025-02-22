
-- Criando a view
CREATE VIEW vw_exportacao_detalhada AS
SELECT
   e."CO_ANO",
   e."CO_MES",
   m."NO_MES",
   e."CO_NCM",
   n."NO_NCM_POR" AS produto,
   e."CO_PAIS",
   p."NO_PAIS" AS destino,
   e."CO_VIA",
   v."NO_VIA" AS modal_transporte,
   e."KG_LIQUIDO",
   e."VL_FOB"
FROM exportacao e
JOIN ncm n ON e."CO_NCM" = n."CO_NCM"
JOIN pais p ON e."CO_PAIS" = p."CO_PAIS"
JOIN via v ON e."CO_VIA" = v."CO_VIA"
JOIN mes m ON e."CO_MES" = m."CO_MES";

-- Consultando a view
SELECT * FROM vw_exportacao_detalhada LIMIT 10;



-- Criando uma Procedure -> Automatizar a inserção de novos registros na tabela exportacao
CREATE OR REPLACE PROCEDURE inserir_importacao(
    p_co_ano INTEGER,
    p_co_mes INTEGER,
    p_co_ncm INTEGER,
    p_co_unid INTEGER,
    p_co_pais INTEGER,
    p_sg_uf_ncm VARCHAR(2),
    p_co_via INTEGER,
    p_co_urf INTEGER,
    p_qt_estat BIGINT,
    p_kg_liquido BIGINT,
    p_vl_fob NUMERIC,
    p_vl_frete NUMERIC,
    p_vl_seguro NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO importacao (
        "CO_ANO", "CO_MES", "CO_NCM", "CO_UNID", "CO_PAIS", "SG_UF_NCM",
        "CO_VIA", "CO_URF", "QT_ESTAT", "KG_LIQUIDO", "VL_FOB", "VL_FRETE", "VL_SEGURO"
    )
    VALUES (
        p_co_ano, p_co_mes, p_co_ncm, p_co_unid, p_co_pais, p_sg_uf_ncm,
        p_co_via, p_co_urf, p_qt_estat, p_kg_liquido, p_vl_fob, p_vl_frete, p_vl_seguro
    );
END;
$$;

-- Chamando a Procedure
CALL inserir_importacao(2024, 1, 10010010, 10, 105, 'SP', 1, 12345, 1000, 5000, 15000.50, 200.75, 50.30);



-- Utilização de uma Trigger
CREATE TABLE audit.auditoria (
    id serial4 PRIMARY KEY,
    tabela varchar(100) NOT NULL,
    operacao varchar(10) NOT NULL,
    usuario varchar(100) NOT NULL DEFAULT current_user,
    data_hora timestamp NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION log_auditoria()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit.auditoria (tabela, operacao)
    VALUES (TG_TABLE_NAME, TG_OP);
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_importacao
AFTER INSERT OR UPDATE OR DELETE ON public.importacao
FOR EACH ROW 
EXECUTE FUNCTION log_auditoria();

CREATE TRIGGER trg_audit_exportacao
AFTER INSERT OR UPDATE OR DELETE ON public.exportacao
FOR EACH ROW 
EXECUTE FUNCTION log_auditoria();



-- Consultas SQL

-- a. Qual bloco econômico enviou mais combustíveis (em peso) para o Brasil em 2024.
SELECT pb."NO_BLOCO",
        sum(i."KG_LIQUIDO") AS "Peso em KG"
FROM importacao i
LEFT JOIN ncm
ON i."CO_NCM" = ncm."CO_NCM"
LEFT JOIN pais p
ON i."CO_PAIS" = p."CO_PAIS"
JOIN pais_bloco pb
ON i."CO_PAIS" = pb."CO_PAIS"
JOIN ncm_cgce nc
ON ncm."CO_CGCE_N3" = nc."CO_CGCE_N3"
WHERE i."CO_ANO" = 2024
AND nc."NO_CGCE_N1_ING" = 'FUELS AND LUBRICANTS'
GROUP BY pb."NO_BLOCO"
ORDER BY "Peso em KG" DESC;

-- b. Quais categorias de produtos tiveram maior volume de importação e exportação nos últimos 5 anos.
WITH Top_Export AS (
   SELECT
       e."CO_NCM" AS NCM_Exportacao,
       nc."NO_CGCE_N3" AS categoria_economica_n3_Exportacao,
       SUM(e."VL_FOB") AS Valor_total_Exportacao,
       ROW_NUMBER() OVER (ORDER BY SUM(e."VL_FOB") DESC) AS rank
   FROM exportacao e
   LEFT JOIN ncm n ON e."CO_NCM" = n."CO_NCM"
   LEFT JOIN ncm_cgce nc ON nc."CO_CGCE_N3" = n."CO_CGCE_N3"
   WHERE e."CO_ANO" BETWEEN 2019 AND 2024
   GROUP BY 1, 2
   ORDER BY Valor_total_Exportacao DESC
   LIMIT 10
),
Top_Import AS (
   SELECT
       i."CO_NCM" AS NCM_Importacao,
       nc."NO_CGCE_N3" AS categoria_economica_n3_Importacao,
       SUM(i."VL_FOB") AS Valor_total_Importacao,
       ROW_NUMBER() OVER (ORDER BY SUM(i."VL_FOB") DESC) AS rank
   FROM importacao i
   LEFT JOIN ncm n ON i."CO_NCM" = n."CO_NCM"
   LEFT JOIN ncm_cgce nc ON nc."CO_CGCE_N3" = n."CO_CGCE_N3"
   WHERE i."CO_ANO" BETWEEN 2019 AND 2024
   GROUP BY 1, 2
   ORDER BY Valor_total_Importacao DESC
   LIMIT 10
)
SELECT
   ti.NCM_Importacao,
   ti.categoria_economica_n3_Importacao,
   ti.Valor_total_Importacao,
   te.NCM_Exportacao,
   te.categoria_economica_n3_Exportacao,
   te.Valor_total_Exportacao
FROM Top_Import ti
JOIN Top_Export te ON ti.rank = te.rank;


--  c. Quais foram os 5 países com maior déficit na balança comercial brasileira? 
WITH total_importado AS (
   SELECT "CO_PAIS", SUM("VL_FOB") AS total_importado
   FROM importacao
   WHERE "CO_ANO" = 2023  -- Filtrando apenas o ano necessário
   GROUP BY "CO_PAIS"
),
total_exportado AS (
   SELECT "CO_PAIS", SUM("VL_FOB") AS total_exportado
   FROM exportacao
   WHERE "CO_ANO" = 2023  -- Filtrando apenas o ano necessário
   GROUP BY "CO_PAIS"
)
SELECT
   p."NO_PAIS",
   COALESCE(i.total_importado, 0) AS total_importado,
   COALESCE(e.total_exportado, 0) AS total_exportado,
   COALESCE(i.total_importado, 0) - COALESCE(e.total_exportado, 0) AS saldo_comercial
FROM pais p
LEFT JOIN total_importado i ON p."CO_PAIS" = i."CO_PAIS"
LEFT JOIN total_exportado e ON p."CO_PAIS" = e."CO_PAIS"
WHERE COALESCE(i.total_importado, 0) > 0 OR COALESCE(e.total_exportado, 0) > 0  --  Exclui países sem transações
ORDER BY saldo_comercial DESC
LIMIT 5;


-- d. Qual país tem a maior tendência de crescimento em suas exportações para o Brasil com base nos últimos 5 anos?
WITH total_importado AS (
   SELECT
       "CO_PAIS",
       "CO_ANO",
       SUM("VL_FOB") AS total_importado
   FROM importacao
   WHERE "CO_ANO" BETWEEN 2019 AND 2024
   GROUP BY "CO_PAIS", "CO_ANO"
),
crescimento_pais AS (
   SELECT
       t1."CO_PAIS",
       p."NO_PAIS",
       t1.total_importado AS valor_inicial,
       t2.total_importado AS valor_final,
       ((t2.total_importado - t1.total_importado) / NULLIF(t1.total_importado, 0)) * 100 AS percentual_crescimento
   FROM total_importado t1
   JOIN total_importado t2
       ON t1."CO_PAIS" = t2."CO_PAIS"
       AND t1."CO_ANO" = 2019
       AND t2."CO_ANO" = 2024
   JOIN pais p ON t1."CO_PAIS" = p."CO_PAIS"
)
SELECT
   "NO_PAIS",
   valor_inicial,
   valor_final,
   percentual_crescimento
FROM crescimento_pais
ORDER BY percentual_crescimento DESC
LIMIT 5;


-- e. Qual Via de Transporte teve o maior valor agregado no comércio exterior no ano de 2024?
SELECT
    "NO_VIA" AS VIA_TRANSPORTE,
    "CO_ANO" AS ANO,
    SUM(VALOR_CIF_IMP) AS VALOR_CIF_IMP,
    SUM(VALOR_FOB_EXP) AS VALOR_FOB_EXP,
    SUM(VALOR_CIF_IMP) + SUM(VALOR_FOB_EXP) AS VALOR_TOTAL_COMERCIO
FROM (
    SELECT
        via."NO_VIA" ,
        i."CO_ANO",
        SUM(i."VL_FOB" + i."VL_FRETE" + i."VL_SEGURO") AS VALOR_CIF_IMP,
        0 AS VALOR_FOB_EXP
    FROM importacao i
    left join via
    on i."CO_VIA" = VIA."CO_VIA"
    WHERE i."CO_ANO" = 2024
    GROUP BY via."NO_VIA", i."CO_ANO"
    UNION ALL
    SELECT
        via."NO_VIA",
        e."CO_ANO",
        0 AS VALOR_CIF_IMP,
        SUM(e."VL_FOB") AS VALOR_FOB_EXP
    FROM exportacao e
    left join via
    on e."CO_VIA" = via."CO_VIA"
    WHERE e."CO_ANO" = 2024
    GROUP BY via."NO_VIA", e."CO_ANO"
) AS combined
GROUP BY VIA_TRANSPORTE, ANO
ORDER BY VALOR_TOTAL_COMERCIO DESC;



-- Consulta em álgebra relacional

-- a. Por quais portos o estado de Minas Gerais exporta?
-- Em Álgebra Relacional
π NO_URF (σ (SG_UF_NCM = MG) AND (CO_VIA=1) exportacao |x|"CO_URF" = "CO_URF" URF)
-- Equivalente em SQL
SELECT DISTINCT u."NO_URF"
FROM exportacao e
JOIN urf u
ON e."CO_URF" = u."CO_URF"
WHERE e."SG_UF_NCM" = 'MG'
AND e."CO_VIA" = 1


-- b. Quais regiões do país importam energia elétrica?
-- Em Álgebra Relacional
energia_importada ← π "SG_UF_NCM", "VL_FOB", "NO_REGIAO" (σ "CO_NCM" = '27160000' (importacao ⋈ "SG_UF_NCM" = "SG_UF" uf))
π "NO_REGIAO", total_importado (ρ posição, "NO_REGIAO", total_importado (γ "NO_REGIAO"; SUM("VL_FOB") → total_importado (energia_importada)))

-- Equivalente SQL
WITH energia_importada AS (
    SELECT i."SG_UF_NCM", i."VL_FOB", u."NO_REGIAO"
    FROM importacao i
    JOIN uf u ON i."SG_UF_NCM" = u."SG_UF"
    WHERE i."CO_NCM" = '27160000'
)
SELECT "NO_REGIAO", SUM("VL_FOB") AS total_importado
FROM energia_importada
GROUP BY "NO_REGIAO"
ORDER BY total_importado DESC;


-- c. Quais países mais exportaram veículos elétricos para o Brasil em 2024?
-- Em Álgebra Relacional
selecao_veiculos ← σ "CO_NCM" = 87038000 ∧ "CO_ANO" = 2024 (importacao)
juncao_pais ← selecao_veiculos ⋈ "CO_PAIS" = "CO_PAIS" pais
agregacao_pais ← γ "NO_PAIS"; SUM("VL_FOB") → total_importado (juncao_pais)
ordenacao_com_ranking ← ρ posição, "NO_PAIS", total_importado (agregacao_pais) 
top_5_paises ← σ posição ≤ 5 (ordenacao_com_ranking)

-- Equivalente SQL
SELECT p."NO_PAIS", SUM(i."VL_FOB") AS total_importado
FROM importacao i
JOIN pais p ON i."CO_PAIS" = p."CO_PAIS"
WHERE i."CO_NCM" = 87038000  -- Apenas veículos elétricos
AND i."CO_ANO" = 2024
GROUP BY p."NO_PAIS"
ORDER BY total_importado DESC
LIMIT 5;

