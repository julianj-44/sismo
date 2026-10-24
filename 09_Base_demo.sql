-- Prueba reproducible (Etapa 6): base de demostración observatorio_demo.
--
-- ORDEN
--   1. En pgAdmin, clic derecho en Databases > Create > Database: observatorio_demo (vacía).
--   2. Abrir Query Tool sobre observatorio_demo y ejecutar, uno por uno:
--        03_Estructura.sql, 06_Vista_eventos_pais.sql, 07_Vistas_mcp.sql
--      (la última línea de 03 otorga CONNECT sobre observatorio_sismico: es inofensiva aquí).
--   3. Ejecutar este archivo, también sobre observatorio_demo.
--   4. En R: Sys.setenv(PGDATABASE='observatorio_demo'); cargar('datos_demo/inicial.json')
--
-- El rol pbi_lector ya existe (los roles son del servidor, no de cada base).

-- Permisos de solo lectura para Power BI sobre la base demo
GRANT CONNECT ON DATABASE observatorio_demo TO pbi_lector;
GRANT USAGE   ON SCHEMA observatorio TO pbi_lector;
GRANT SELECT  ON observatorio.v_eventos,
                 observatorio.v_cargas,
                 observatorio.v_eventos_pais,
                 observatorio.v_paises TO pbi_lector;

-- Comprobación: debe devolver 4 filas con tiene_select = true
SELECT c.relname AS vista,
       has_table_privilege('pbi_lector', c.oid, 'SELECT') AS tiene_select
FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'observatorio' AND c.relkind = 'v'
ORDER BY c.relname;

-- ---------------------------------------------------------------------
-- VERIFICACIONES DE LA DEMOSTRACIÓN (correr con los mismos filtros del informe)
-- ---------------------------------------------------------------------

-- A) Antes de cargar: la tabla debe estar vacía.
SELECT count(*) AS eventos FROM observatorio.eventos;                  -- 0

-- B) Después de cargar inicial.json: 9.882 eventos, ids únicos, sin duplicados.
SELECT count(*) AS eventos, count(DISTINCT id) AS ids_unicos FROM observatorio.eventos;

-- C) Después de cargar reservado.json: 9.902 (= 9.882 + 20).
--    Tras repetir la misma carga el valor NO cambia.
SELECT count(*) AS eventos, count(DISTINCT id) AS ids_unicos FROM observatorio.eventos;

-- D) Registro de las cargas: la 1.ª con afectados = 9.882, la 2.ª con 20, la 3.ª con 0.
SELECT id, origen, estado, procesados, afectados, fin_utc
FROM observatorio.v_cargas ORDER BY id;

-- E) Duplicados (debe devolver 0 filas).
SELECT id, count(*) FROM observatorio.eventos GROUP BY id HAVING count(*) > 1;
