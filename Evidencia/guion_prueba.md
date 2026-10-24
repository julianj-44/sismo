# Guion de la prueba reproducible

Reproducción controlada de datos reales del USGS (captura del 18 oct 2026 00:31 UTC, fechas originales conservadas). Lotes en `datos_demo/`: `inicial.json` (9.882 eventos) y `reservado.json` (20 eventos).

## Preparación (antes de la sustentación)

| # | Paso | Hecho |
|---|---|---|
| 1 | Detener el modo continuo en RStudio (Esc/Stop). No ejecutar `cargar()` sin archivo ni `continuar()` hasta terminar | [ ] |
| 2 | Crear la base vacía `observatorio_demo` en pgAdmin | [ ] |
| 3 | En esa base, ejecutar `03_Estructura.sql`, `06_Vista_eventos_pais.sql`, `07_Vistas_mcp.sql` y `09_Base_demo.sql` | [ ] |
| 4 | Comprobar que las 4 vistas salen con `tiene_select = true` | [ ] |
| 5 | En R: `Sys.setenv(PGDATABASE='observatorio_demo')`, `source('04_Carga_USGS.R')`, `cargar('datos_demo/inicial.json')` | [ ] |
| 6 | Verificar en pgAdmin (consulta B de `09_Base_demo.sql`): 9.882 eventos y 9.882 ids únicos | [ ] |
| 7 | En Power BI Desktop, *Archivo → Guardar como* una copia del informe y, en *Transformar datos → Configuración de origen de datos*, cambiar `observatorio_sismico` por `observatorio_demo` en las tres tablas | [ ] |
| 8 | Quitar los filtros y segmentadores que oculten eventos; confirmar actualización de página de 1 minuto en la página que se usará | [ ] |
| 9 | Ensayar antes con otra carpeta (`preparar_demo('datos_ensayo')`) y otra base: el lote reservado real no puede estar cargado | [ ] |

No usar `preparar_demo()` sobre `datos_demo/`: la carpeta ya existe y la función se detiene.

## Sustentación, en orden

| # | Acción | Resultado esperado | Registro | Captura |
|---|---|---|---|---|
| 1 | Mostrar el conteo inicial en Power BI | 9.882 | [COMPLETAR] | `Evidencia/1_antes.png` |
| 2 | `cargar('datos_demo/reservado.json')` | Procesados: 20; insertados: 20 | [COMPLETAR] | |
| 3 | Contrastar el aumento con SQL (consulta C) | 9.902 | [COMPLETAR] | `Evidencia/2_sql_despues.png` |
| 4 | Esperar el refresco automático (máx. 1 min) | Power BI muestra 9.902 sin acción manual | [COMPLETAR] | `Evidencia/3_despues.png` |
| 5 | Repetir exactamente `cargar('datos_demo/reservado.json')` | afectados = 0; el conteo sigue en 9.902; 0 duplicados (consulta E) | [COMPLETAR] | `Evidencia/4_repeticion.png` |

Al final, modo continuo: `cargar()` y `continuar(300)`.

## Evidencia a guardar en `Evidencia/`

- Capturas 1 a 4 de la tabla anterior.
- Resultado de las consultas B, C, D y E de `09_Base_demo.sql` en pgAdmin.
- `datos_demo/procedencia.txt` (fuente y fecha de descarga).
