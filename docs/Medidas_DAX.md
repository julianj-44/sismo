# Medidas DAX — Observatorio sísmico

Tablas de Power BI (DirectQuery): `v_eventos_pais` y `v_cargas`. Las dos son vistas del esquema `observatorio`.
Crear cada medida con clic derecho sobre la tabla → **Nueva medida**, una por una y en este orden.

## En `v_eventos_pais`

```dax
Eventos = DISTINCTCOUNT(v_eventos_pais[id])

Magnitud máxima = MAX(v_eventos_pais[magnitud])

Último evento UTC = MAX(v_eventos_pais[fecha_evento])

Eventos Colombia =
CALCULATE([Eventos], v_eventos_pais[grupo] = "Colombia")

% Colombia = DIVIDE([Eventos Colombia], [Eventos])

Magnitud máx. Colombia =
CALCULATE([Magnitud máxima], v_eventos_pais[grupo] = "Colombia")
```

## En `v_cargas`

```dax
Última carga exitosa UTC =
CALCULATE(MAX(v_cargas[fin_utc]), v_cargas[estado] = "ok")
```

## Formato (Herramientas de medida)

| Medida | Formato |
|---|---|
| Eventos | Número entero, separador de miles |
| Magnitud máxima, Magnitud máx. Colombia | 1 decimal |
| % Colombia | Porcentaje, 1 decimal |
| Último evento UTC, Última carga exitosa UTC | Fecha y hora, `dd mmm yyyy HH:mm` |

## Qué alimenta cada ficha

| Ficha | Medida |
|---|---|
| Eventos | `Eventos` |
| Magnitud máxima | `Magnitud máxima` |
| Último evento (UTC) | `Último evento UTC` |
| Eventos en Colombia | `Eventos Colombia` (con `% Colombia` y `Magnitud máx. Colombia` en la nota) |
| Calidad y actualidad | `Última carga exitosa UTC` |

## Valores esperados (SQL del 24 oct 2026, sin filtros)

Sirven para validar contra SQL bajo los mismos filtros. Detalle y consultas en `Evidencia/validacion_sql.md`.

| Medida | Valor |
|---|---|
| Eventos | 10.514 |
| Magnitud máxima | 7,7 |
| Eventos Colombia | 36 |
| % Colombia | 0,34 % |
| Magnitud máx. Colombia | 4,8 |
| Último evento UTC | 20 oct 2026 21:38 |
| Última carga exitosa UTC | 20 oct 2026 21:43 |

## Notas

- `fecha_evento` es `timestamptz`: el conector de PostgreSQL puede mostrarla en hora local (Colombia, UTC-5). Si `Último evento UTC` sale 13:20 en vez de 18:20, hay que devolver la fecha como `timestamp without time zone` en UTC desde la vista SQL.
- `v_cargas` ya viene en UTC (`timestamp without time zone`): no tiene ese problema.
- `v_cargas` no se relaciona con `v_eventos_pais`: las cargas describen ejecuciones, no son una dimensión del evento.
- Los filtros de Colombia están dentro de las medidas, así que esas fichas no cambian al elegir otro país en «Resaltar país».
