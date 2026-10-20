-- Vista v_eventos_pais: cada sismo con su país y un grupo para destacar a Colombia.
-- Ejecutar en pgAdmin (Query Tool) conectado a la base del proyecto,
-- como postgres o como el dueño de las tablas. pbi_lector es de solo lectura.

CREATE OR REPLACE VIEW observatorio.v_eventos_pais AS
SELECT e.*,
       (e.fecha_evento AT TIME ZONE 'UTC')::date AS fecha_dia,  -- día en UTC para el eje de Power BI
       p.pais,
       p.subregion,
       CASE WHEN p.pais = 'Colombia' THEN 'Colombia'
            WHEN p.pais IS NOT NULL  THEN 'Resto de Latinoamérica'
            ELSE 'Resto del mundo' END AS grupo
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
