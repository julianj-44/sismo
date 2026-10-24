-- Vistas para que el MCP (y Power BI) lean sin acceso a las tablas.
-- Ejecutar en pgAdmin conectado a la base del proyecto, como postgres o el dueño de las tablas.
-- Requiere haber ejecutado antes 06_Vista_eventos_pais.sql.
--
-- Con 06 + 07, pbi_lector ve todo lo necesario por vistas:
--   v_eventos_pais -> sismos con país y grupo (eventos + paises_latam)
--   v_cargas       -> estado de las cargas
--   v_paises       -> catálogo de países

-- v_cargas ya existe (la crea 03_Estructura.sql, con columnas como inicio_utc): no se recrea,
-- solo se le da el GRANT.

CREATE OR REPLACE VIEW observatorio.v_paises AS
SELECT nombre_usgs, pais, subregion, incluir
FROM observatorio.paises_latam;

GRANT USAGE  ON SCHEMA observatorio TO pbi_lector;
GRANT SELECT ON observatorio.v_cargas, observatorio.v_paises TO pbi_lector;

-- Verificación: las tres vistas deben ser legibles y dar 1, 36 y 9.729 filas hoy.
-- SELECT (SELECT count(*) FROM observatorio.v_cargas)       AS cargas,
--        (SELECT count(*) FROM observatorio.v_paises)       AS paises,
--        (SELECT count(*) FROM observatorio.v_eventos_pais) AS eventos;

-- OPCIONAL (mínimo privilegio): quitar el acceso directo a las tablas.
-- Ejecutar solo cuando el MCP y Power BI ya lean bien por las vistas.
-- REVOKE SELECT ON ALL TABLES IN SCHEMA observatorio FROM pbi_lector;
-- GRANT  SELECT ON observatorio.v_eventos_pais, observatorio.v_cargas, observatorio.v_paises TO pbi_lector;
