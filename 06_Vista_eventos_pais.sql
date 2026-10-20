-- Vista v_eventos_pais: cada sismo con su país y un grupo para destacar a Colombia.
-- Ejecutar en pgAdmin (Query Tool) conectado a la base del proyecto,
-- como postgres o como el dueño de las tablas. pbi_lector es de solo lectura.

-- Las fechas salen como UTC sin zona horaria (timestamp): con timestamptz, Power BI
-- las convierte a la hora del equipo (UTC-5) y 18:20 UTC se vería como 13:20.
-- Cambiar el tipo de una columna exige DROP + CREATE (CREATE OR REPLACE no puede).
-- Ninguna otra vista depende de esta, pero el DROP borra el GRANT: se repite abajo.
DROP VIEW IF EXISTS observatorio.v_eventos_pais;

CREATE VIEW observatorio.v_eventos_pais AS
SELECT e.id,
       e.fecha_evento       AT TIME ZONE 'UTC' AS fecha_evento,
       e.actualizado_fuente AT TIME ZONE 'UTC' AS actualizado_fuente,
       e.lugar, e.magnitud, e.tipo_magnitud, e.longitud, e.latitud, e.profundidad_km, e.url,
       e.fecha_carga        AT TIME ZONE 'UTC' AS fecha_carga,
       (e.fecha_evento AT TIME ZONE 'UTC')::date AS fecha_dia,  -- día en UTC para el eje de Power BI
       p.pais,
       p.subregion,
       CASE WHEN p.pais = 'Colombia' THEN 'Colombia'
            WHEN p.pais IS NOT NULL  THEN 'Resto de Latinoamérica'
            ELSE 'Resto del mundo' END AS grupo,
       -- Intervalos para los histogramas (en SQL: las columnas calculadas de DAX no agrupan bien en DirectQuery)
       floor(e.magnitud * 2) / 2                 AS rango_magnitud,       -- intervalos de 0,5
       floor(e.profundidad_km / 50) * 50         AS rango_profundidad_km, -- intervalos de 50 km (Sturges: k=15, ancho ~45 km)
       -- Intervalos de magnitud de 1 unidad como texto (ejes legibles); negativas agrupadas en el primero.
       CASE WHEN e.magnitud < 0 THEN 'Menos de 0'
            WHEN e.magnitud < 1 THEN '0 a 1'
            WHEN e.magnitud < 2 THEN '1 a 2'
            WHEN e.magnitud < 3 THEN '2 a 3'
            WHEN e.magnitud < 4 THEN '3 a 4'
            WHEN e.magnitud < 5 THEN '4 a 5'
            WHEN e.magnitud < 6 THEN '5 a 6'
            WHEN e.magnitud IS NOT NULL THEN '6 o más' END AS intervalo_magnitud,
       CASE WHEN e.magnitud < 0 THEN 1
            WHEN e.magnitud < 1 THEN 2
            WHEN e.magnitud < 2 THEN 3
            WHEN e.magnitud < 3 THEN 4
            WHEN e.magnitud < 4 THEN 5
            WHEN e.magnitud < 5 THEN 6
            WHEN e.magnitud < 6 THEN 7
            WHEN e.magnitud IS NOT NULL THEN 8 END AS orden_magnitud,
       -- Tramos geofisicos: la profundidad es muy asimetrica (mediana 8 km, p95 101 km) y con intervalos
       -- iguales el 85 % cae en una sola barra. Los valores negativos (sobre el nivel del mar) van al primer tramo.
       CASE WHEN e.profundidad_km <  10 THEN 'Menos de 10 km'
            WHEN e.profundidad_km <  35 THEN '10 a 35 km'
            WHEN e.profundidad_km <  70 THEN '35 a 70 km'
            WHEN e.profundidad_km < 150 THEN '70 a 150 km'
            WHEN e.profundidad_km < 300 THEN '150 a 300 km'
            WHEN e.profundidad_km IS NOT NULL THEN 'Más de 300 km' END AS tramo_profundidad,
       CASE WHEN e.profundidad_km <  10 THEN 1
            WHEN e.profundidad_km <  35 THEN 2
            WHEN e.profundidad_km <  70 THEN 3
            WHEN e.profundidad_km < 150 THEN 4
            WHEN e.profundidad_km < 300 THEN 5
            WHEN e.profundidad_km IS NOT NULL THEN 6 END AS orden_tramo
FROM observatorio.eventos e
LEFT JOIN observatorio.paises_latam p                -- LEFT: no se pierde ningún sismo
  ON e.lugar ILIKE '%' || p.nombre_usgs              -- lugar TERMINA en el nombre del país
 AND p.incluir
 AND e.lugar NOT ILIKE '%New Mexico';                -- Nuevo México (EE. UU.) no es México

-- Sin esto Power BI da "permission denied".
GRANT SELECT ON observatorio.v_eventos_pais TO pbi_lector;

-- Verificación 1: debe devolver el mismo total que eventos (9.729 hoy); si es mayor, hay duplicados.
SELECT count(*) FROM observatorio.v_eventos_pais;

-- Verificación 2: sismos y magnitud máxima por grupo.
SELECT grupo, count(*) AS sismos, max(magnitud) AS mag_max
  FROM observatorio.v_eventos_pais GROUP BY grupo ORDER BY sismos DESC;

-- OPCIONAL (mínimo privilegio): que pbi_lector lea solo vistas, no las tablas.
-- Ejecutar DESPUÉS de comprobar que Power BI lee bien la vista. Las vistas siguen
-- funcionando porque se ejecutan con los privilegios de su dueño.
-- REVOKE SELECT ON ALL TABLES IN SCHEMA observatorio FROM pbi_lector;
-- GRANT  SELECT ON observatorio.v_eventos_pais TO pbi_lector;   -- ya dado arriba
-- GRANT  SELECT ON observatorio.v_cargas       TO pbi_lector;   -- si usas la vista de cargas
