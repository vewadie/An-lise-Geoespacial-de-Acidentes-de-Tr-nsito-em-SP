-- ============================================================
-- Schema PostGIS: Sinistros de Trânsito em São Paulo
-- Fonte: Infosiga SP (sinistros_2015-2021.csv + sinistros_2022-2026.csv)
-- ============================================================

CREATE EXTENSION IF NOT EXISTS postgis;

-- ------------------------------------------------------------
-- Tabela: municipios
-- Geometria dos municípios do estado de SP (fonte: IBGE 2022)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS acidentes CASCADE;
DROP TABLE IF EXISTS municipios CASCADE;

CREATE TABLE municipios (
    id           SERIAL PRIMARY KEY,
    codigo_ibge  TEXT UNIQUE NOT NULL,
    nome         TEXT NOT NULL,
    geom         GEOMETRY(MultiPolygon, 4326)
);

CREATE INDEX idx_municipios_geom   ON municipios USING GIST (geom);
CREATE INDEX idx_municipios_codigo ON municipios (codigo_ibge);

-- ------------------------------------------------------------
-- Tabela: acidentes
-- Registros de sinistros (fonte: Infosiga SP)
-- Colunas mapeadas de: tp_sinistro_primario → tipo_acidente,
-- tipo_via → causa_acidente, qtd_gravidade_* → mortos/feridos/ilesos
-- ------------------------------------------------------------
CREATE TABLE acidentes (
    id_sinistro           TEXT,
    ano                   INT,
    mes                   INT,
    data_ocorrencia       DATE,
    dia_semana            TEXT,
    hora                  TEXT,
    turno                 TEXT,
    tipo_local            TEXT,
    municipio_id          INT REFERENCES municipios(id) ON DELETE SET NULL,
    municipio_nome        TEXT,
    regiao_administrativa TEXT,
    tipo_acidente         TEXT,         -- tp_sinistro_primario
    causa_acidente        TEXT,         -- tipo_via
    mortos                INT DEFAULT 0, -- qtd_gravidade_fatal
    feridos_graves        INT DEFAULT 0, -- qtd_gravidade_grave
    feridos_leves         INT DEFAULT 0, -- qtd_gravidade_leve
    ilesos                INT DEFAULT 0, -- qtd_gravidade_ileso
    total_vitimas         INT DEFAULT 0,
    latitude              DOUBLE PRECISION,
    longitude             DOUBLE PRECISION,
    geom                  GEOMETRY(Point, 4326),
    fonte                 TEXT DEFAULT 'Infosiga SP'
);

CREATE INDEX idx_acidentes_geom      ON acidentes USING GIST (geom);
CREATE INDEX idx_acidentes_municipio ON acidentes (municipio_id);
CREATE INDEX idx_acidentes_data      ON acidentes (data_ocorrencia);
CREATE INDEX idx_acidentes_ano_mes   ON acidentes (ano, mes);
CREATE INDEX idx_acidentes_tipo      ON acidentes (tipo_acidente);
CREATE INDEX idx_acidentes_turno     ON acidentes (turno);

-- ------------------------------------------------------------
-- View: resumo por município
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vw_resumo_municipio AS
SELECT
    m.nome                           AS municipio,
    m.codigo_ibge,
    COUNT(a.id_sinistro)             AS total_sinistros,
    SUM(a.mortos)                    AS total_mortos,
    SUM(a.feridos_graves)            AS total_feridos_graves,
    SUM(a.feridos_leves)             AS total_feridos_leves,
    ROUND(AVG(a.mortos)::numeric, 4) AS media_mortos_por_sinistro,
    m.geom
FROM municipios m
LEFT JOIN acidentes a ON a.municipio_id = m.id
GROUP BY m.id, m.nome, m.codigo_ibge, m.geom;

-- ------------------------------------------------------------
-- View: série temporal mensal
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vw_serie_temporal AS
SELECT
    ano,
    mes,
    TO_DATE(ano::text || '-' || LPAD(mes::text, 2, '0') || '-01', 'YYYY-MM-DD') AS periodo,
    COUNT(*)                            AS total_sinistros,
    SUM(mortos)                         AS total_mortos,
    SUM(feridos_graves + feridos_leves) AS total_feridos
FROM acidentes
GROUP BY ano, mes
ORDER BY ano, mes;