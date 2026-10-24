# Validación: Power BI contra SQL

Base `observatorio_sismico` (PostgreSQL 17.11), consulta del **24 oct 2026 23:33 UTC**, sin filtros ni segmentadores. Las vistas son las mismas que lee Power BI: `observatorio.v_eventos_pais` y `observatorio.v_cargas`.

## Consulta

```sql
SELECT now() AT TIME ZONE 'UTC' AS consulta_utc,
 count(DISTINCT id) AS eventos,
 max(magnitud) AS magnitud_maxima,
 max(fecha_evento) AS ultimo_evento_utc,
 count(DISTINCT id) FILTER (WHERE grupo = 'Colombia') AS eventos_colombia,
 round(100.0 * count(DISTINCT id) FILTER (WHERE grupo = 'Colombia') / count(DISTINCT id), 2) AS pct_colombia,
 max(magnitud) FILTER (WHERE grupo = 'Colombia') AS mag_max_colombia,
 count(DISTINCT id) FILTER (WHERE grupo <> 'Resto del mundo') AS eventos_latam,
 count(*) - count(DISTINCT id) AS ids_duplicados,
 count(*) FILTER (WHERE magnitud IS NULL) AS sin_magnitud,
 count(*) FILTER (WHERE profundidad_km IS NULL) AS sin_profundidad,
 count(*) FILTER (WHERE magnitud < 0) AS mag_negativa,
 count(*) FILTER (WHERE profundidad_km < 0) AS prof_negativa,
 (SELECT max(fin_utc) FROM observatorio.v_cargas WHERE estado = 'ok') AS ultima_carga_ok_utc,
 (SELECT count(*) FROM observatorio.v_cargas WHERE estado = 'ok') AS cargas_ok,
 (SELECT count(*) FROM observatorio.v_cargas WHERE estado <> 'ok') AS cargas_fallidas
FROM observatorio.v_eventos_pais;
```

## Resultado y contraste

| Indicador | Medida DAX | SQL | Power BI | ¿Coincide? |
|---|---|---|---|---|
| Eventos | `Eventos` | 10.514 | 10.514 | Sí |
| Magnitud máxima | `Magnitud máxima` | 7,7 | 7,7 | Sí |
| Último evento UTC | `Último evento UTC` | 20 oct 2026 21:38 | 20 oct 2026 21:38 | Sí |
| Eventos Colombia | `Eventos Colombia` | 36 | 36 | Sí |
| % Colombia | `% Colombia` | 0,34 % | 0,34 % | Sí |
| Magnitud máx. Colombia | `Magnitud máx. Colombia` | 4,8 | 4,8 | Sí |
| Eventos Latinoamérica | `Eventos Latinoamérica` | 292 | 292 | Sí |
| Ids duplicados | `Ids duplicados` | 0 | 0 | Sí |
| Sin magnitud / sin profundidad | `Eventos sin magnitud` / `Eventos sin profundidad` | 0 / 0 | 0 / 0 | Sí |
| Magnitud / profundidad negativa | `Eventos magnitud negativa` / `Eventos profundidad negativa` | 479 / 219 | 479 / 219 | Sí |
| Última carga exitosa UTC | `Última carga exitosa UTC` | 20 oct 2026 21:43 | 20 oct 2026 21:43 | Sí |
| Cargas ok / fallidas | `Cargas exitosas` / `Cargas fallidas` | 2 / 0 | 2 / 0 | Sí |

Si «Último evento UTC» o la última carga salen 5 horas antes en Power BI (por ejemplo 16:38 en vez de 21:38), es el conector convirtiendo a hora local; la vista ya devuelve UTC sin zona, así que revisar el formato de la medida.

## Evidencia a adjuntar

- Captura de la página *Panorama* sin segmentadores, con las tarjetas visibles.
- Captura de la página *Calidad y Actualidad*.
- Captura del resultado de la consulta en pgAdmin.
