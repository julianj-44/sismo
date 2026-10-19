

CREATE OR REPLACE VIEW observatorio.v_eventos_latam AS
    SELECT e.*, p.pais, p.subregion
    FROM observatorio.v_eventos e
    JOIN observatorio.paises_latam p
      ON p.incluir
     AND rtrim(e.lugar) ~*
         ('(^|[[:space:],])' || p.nombre_usgs || '$')
    WHERE NOT (p.nombre_usgs = 'Mexico'
      AND rtrim(e.lugar) ~* '(New Mexico|Gulf of Mexico)$');

SELECT count(*) AS latam,
      (SELECT count(*) FROM observatorio.v_eventos) AS total
    FROM observatorio.v_eventos_latam;


SELECT id, count(*) FROM observatorio.v_eventos_latam
    GROUP BY id HAVING count(*) > 1;


SELECT pais, subregion, count(*) AS eventos,
	max(magnitud) AS magnitud_maxima
    FROM observatorio.v_eventos_latam
    GROUP BY pais, subregion ORDER BY eventos DES


SELECT trim(substring(lugar from '[^,]+$')) AS texto,
      count(*) AS eventos
    FROM observatorio.v_eventos e
    WHERE NOT EXISTS (SELECT 1 FROM observatorio.v_eventos_latam l
                      WHERE l.id = e.id)
      AND latitud BETWEEN -56 AND 33
      AND longitud BETWEEN -120 AND -30
    GROUP BY texto ORDER BY eventos DESC LIMIT 60;




SELECT pais, count(*) AS eventos,
    min(magnitud) AS magnitud_minima,
    count(*) FILTER (WHERE magnitud < 4.5) AS menores_4_5,
    count(*) FILTER (WHERE magnitud >= 4.5) AS desde_4_5
    FROM observatorio.v_eventos_latam
    GROUP BY pais ORDER BY eventos DESC;



SELECT count(*) AS eventos,
    count(*) FILTER (WHERE magnitud < 4.5) AS menores_4_5,
    min(magnitud) AS magnitud_minima
    FROM observatorio.v_eventos
    WHERE lugar ~* '(Texas|New Mexico|CA)$';



SELECT count(*) AS total,
      count(*) FILTER (WHERE magnitud >= 4.5) AS desde_4_5,
      count(*) FILTER (WHERE magnitud < 4.5) AS menores_4_5,
      count(*) FILTER (WHERE magnitud IS NULL) AS sin_magnitud
    FROM observatorio.v_eventos;
	


SELECT count(*) AS eventos, count(DISTINCT id) AS ids_unicos
      FROM observatorio.eventos;
