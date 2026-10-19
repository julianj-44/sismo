SELECT count(*) AS eventos, count(DISTINCT id) AS ids_unicos FROM observatorio.eventos;
SELECT id, count(*) FROM observatorio.eventos GROUP BY id HAVING count(*) > 1;
SELECT count(*) FILTER (WHERE magnitud IS NULL) AS sin_magnitud,
 count(*) FILTER (WHERE profundidad_km IS NULL) AS sin_profundidad,
 max(fecha_evento) AS ultimo_evento FROM observatorio.eventos;
SELECT * FROM observatorio.cargas ORDER BY id DESC LIMIT 10;
SELECT dia_utc, count(*) AS eventos, max(magnitud) AS magnitud_maxima
FROM observatorio.v_eventos GROUP BY dia_utc ORDER BY dia_utc;
-- Añadan consultas con exactamente los filtros utilizados en Power BI.



	