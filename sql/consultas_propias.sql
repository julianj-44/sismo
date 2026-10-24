-- Consultas propias del grupo (Etapa 4). Solo lectura: se pueden ejecutar tal cual en pgAdmin
-- (Query Tool) sobre observatorio_sismico, con postgres o pbi_lector.
-- Requiere 03_Estructura.sql, 06_Vista_eventos_pais.sql y 07_Vistas_paises.sql.
-- Todas leen las vistas que usa Power BI, así que sirven para contrastar sus resultados
-- bajo los mismos filtros. Las fechas están en UTC. Los faltantes no se imputan: se informan.

-- 1) Sismos y magnitud máxima por país de Latinoamérica.
--    Numerador: eventos del país. Unidad: eventos y magnitud. Período: todo lo cargado.
--    Faltantes: max() ignora las magnitudes vacías; no se reemplazan por 0.
SELECT pais, subregion,
       count(*)       AS eventos,
       max(magnitud)  AS magnitud_maxima
FROM observatorio.v_eventos_pais
WHERE grupo <> 'Resto del mundo'
GROUP BY pais, subregion
ORDER BY eventos DESC;

-- 2) Colombia frente al resto de Latinoamérica, solo magnitud >= 4,5.
--    El catálogo registra de forma desigual los sismos pequeños según la región; con el mismo
--    umbral la comparación es justa. La magnitud no es intensidad ni energía y mezcla tipos
--    (mb, ml, mww...), así que las medianas son orientativas.
SELECT grupo,
       count(*)                                                   AS eventos,
       round(percentile_cont(0.5) WITHIN GROUP (ORDER BY magnitud)::numeric, 2)       AS mediana_magnitud,
       max(magnitud)                                              AS magnitud_maxima,
       round(percentile_cont(0.5) WITHIN GROUP (ORDER BY profundidad_km)::numeric, 1) AS mediana_profundidad_km
FROM observatorio.v_eventos_pais
WHERE grupo IN ('Colombia', 'Resto de Latinoamérica')
  AND magnitud >= 4.5
GROUP BY grupo
ORDER BY grupo;

-- 3) Frecuencia diaria de sismos en Colombia (día UTC).
--    Solo aparecen los días con al menos un evento; los días sin eventos no tienen fila.
SELECT fecha_dia,
       count(*)      AS eventos,
       max(magnitud) AS magnitud_maxima
FROM observatorio.v_eventos_pais
WHERE grupo = 'Colombia'
GROUP BY fecha_dia
ORDER BY fecha_dia;

-- 4) Perfil de profundidad por grupo.
--    Numerador: eventos del tramo. Denominador: eventos del mismo grupo con profundidad conocida.
--    Unidad: porcentaje. Las profundidades negativas son válidas y entran en «Menos de 10 km».
SELECT grupo, tramo_profundidad,
       count(*) AS eventos,
       round(100.0 * count(*) / sum(count(*)) OVER (PARTITION BY grupo), 1) AS porcentaje_del_grupo
FROM observatorio.v_eventos_pais
WHERE grupo IN ('Colombia', 'Resto de Latinoamérica')
  AND tramo_profundidad IS NOT NULL
GROUP BY grupo, tramo_profundidad, orden_tramo
ORDER BY grupo, orden_tramo;

-- 5) Calidad y actualidad: faltantes, duplicados, evento más reciente y última carga exitosa.
--    Sirve para contrastar la página «Calidad y actualidad» del informe.
SELECT count(*)                                  AS eventos,
       count(DISTINCT id)                        AS ids_unicos,
       count(*) - count(DISTINCT id)             AS ids_duplicados,
       count(*) FILTER (WHERE magnitud IS NULL)       AS sin_magnitud,
       count(*) FILTER (WHERE profundidad_km IS NULL) AS sin_profundidad,
       max(fecha_evento)                         AS ultimo_evento_utc,
       (SELECT max(fin_utc) FROM observatorio.v_cargas WHERE estado = 'ok') AS ultima_carga_ok_utc
FROM observatorio.v_eventos_pais;

-- 6) Contraste con Power BI: los indicadores del informe calculados en SQL, sin filtros.
--    Cada columna corresponde a una medida del informe (ver Documentacion/Medidas_DAX.md).
--    Las fechas salen en UTC sin zona horaria; si Power BI las muestra 5 horas distintas,
--    revisar el formato de la medida, no la consulta.
SELECT now() AT TIME ZONE 'UTC'                                          AS consulta_utc,
       count(DISTINCT id)                                                AS eventos,
       max(magnitud)                                                     AS magnitud_maxima,
       max(fecha_evento)                                                 AS ultimo_evento_utc,
       count(DISTINCT id) FILTER (WHERE grupo = 'Colombia')              AS eventos_colombia,
       round(100.0 * count(DISTINCT id) FILTER (WHERE grupo = 'Colombia') / count(DISTINCT id), 2) AS pct_colombia,
       max(magnitud) FILTER (WHERE grupo = 'Colombia')                   AS mag_max_colombia,
       count(DISTINCT id) FILTER (WHERE grupo <> 'Resto del mundo')      AS eventos_latam,
       count(*) - count(DISTINCT id)                                     AS ids_duplicados,
       count(*) FILTER (WHERE magnitud IS NULL)                          AS sin_magnitud,
       count(*) FILTER (WHERE profundidad_km IS NULL)                    AS sin_profundidad,
       count(*) FILTER (WHERE magnitud < 0)                              AS mag_negativa,
       count(*) FILTER (WHERE profundidad_km < 0)                        AS prof_negativa,
       (SELECT max(fin_utc) FROM observatorio.v_cargas WHERE estado = 'ok')  AS ultima_carga_ok_utc,
       (SELECT count(*) FROM observatorio.v_cargas WHERE estado = 'ok')      AS cargas_ok,
       (SELECT count(*) FROM observatorio.v_cargas WHERE estado <> 'ok')     AS cargas_fallidas
FROM observatorio.v_eventos_pais;
