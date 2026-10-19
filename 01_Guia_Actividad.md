# Actividad complementaria — Práctica Profesional
## Observatorio sísmico con PostgreSQL local y Power BI

**Universidad del Valle · Escuela de Estadística**  
**Docente:** César Andrés Ojeda Echeverri  
**Modalidad:** trabajo por grupos · **Semestre:** 2026-2  
Fechas, integrantes por grupo y duración de la sustentación: se comunicarán en el campus virtual.

## 1. Propósito y situación profesional
Un equipo de seguimiento necesita consultar eventos sísmicos, explorar su distribución geográfica y temporal y conocer la actualidad de la información. Cada grupo construirá una solución reproducible con datos abiertos del USGS: captura en R, almacenamiento en PostgreSQL y visualización en Power BI Desktop.

El objetivo es integrar datos reales, diseñar consultas, construir indicadores e interpretar resultados. El análisis será descriptivo; el tablero no es un sistema de predicción ni de alerta temprana.

## 2. Producto esperado y herramientas
Un informe interactivo de tres páginas, conectado mediante DirectQuery a una base PostgreSQL local. Debe mostrar cambios de la base sin importar nuevamente los datos ni pulsar actualización manual durante la demostración.

Cada grupo utilizará un computador Windows con PostgreSQL, pgAdmin, R, RStudio y Power BI Desktop. El grupo instala y administra su base local. No se requiere servidor del docente, publicación web, licencia Pro ni prueba temporal. Las cuentas institucionales conservan el alcance disponible; el trabajo se presenta en Desktop.

El flujo es: USGS → script R → PostgreSQL local → Power BI Desktop. El script consulta la fuente; Power BI consulta la base. Son dos procesos distintos. El intervalo propuesto es 300 segundos entre cargas y 60 segundos de actualización de la página abierta. La latencia incluye publicación de la fuente, carga y consulta; no se promete inmediatez absoluta.

## 3. Organización y responsabilidades
Designen un equipo de integración y distribuyan captura/calidad, SQL, visualización e interpretación. Todos deben explicar el flujo completo y participar en la sustentación. Compartir el archivo PBIX no comparte la base: otro equipo deberá reconstruirla con los scripts y configurar sus credenciales.

El docente proporciona esta guía y código inicial. El grupo adapta, documenta, valida y completa el producto. El tablero y las conclusiones deben ser elaboración del grupo.

## 4. Desarrollo por etapas
### Etapa 1. Definición del problema
Identifiquen un usuario y formulen tres preguntas que el tablero permita responder. Delimiten período, cobertura y criterios de inclusión. Expliquen qué decisiones o tareas apoya cada indicador.

### Etapa 2. Primer hito técnico
Sigan 02_Instalacion_y_Ejecucion.md. Creen una base vacía llamada observatorio_sismico, ejecuten el SQL y carguen datos. Conecten Power BI por DirectQuery y muestren el conteo en una tarjeta. Verifiquen el mismo número mediante SQL antes de diseñar el resto.

### Etapa 3. Calidad y organización
Documenten tipos, unidades, zonas horarias, faltantes y unicidad del identificador. No sustituyan magnitudes faltantes por cero. Conserven valores negativos válidos; no equiparen magnitud con intensidad ni con energía. Distingan tipos de magnitud y expliquen comparaciones.

La fuente inicial es el feed de todos los eventos de los últimos 30 días; el código conserva solo los de tipo earthquake. La base acumula eventos consultados; no elimina un registro porque deje de aparecer en la ventana móvil. Por ello definan explícitamente los filtros temporales del informe. El ejemplo no reconcilia eliminaciones o fusiones del catálogo ni revisiones de eventos que ya salieron de esa ventana: declárenlo como limitación.

### Etapa 4. Consultas e indicadores
Creen al menos dos consultas o vistas propias con utilidad analítica. Definan por escrito numerador, denominador cuando corresponda, unidad, período y tratamiento de faltantes de sus indicadores. Contrasten tres resultados de Power BI con SQL bajo los mismos filtros.

### Etapa 5. Informe interactivo
| Página | Contenido mínimo |
|---|---|
| Panorama | Conteo de eventos, magnitud máxima, último evento, mapa o alternativa geográfica y filtros por período, magnitud y profundidad. |
| Análisis | Evolución temporal, distribución de magnitud y profundidad, comparación argumentada de subconjuntos y tres hallazgos. |
| Calidad y actualidad | Faltantes, última carga exitosa, evento más reciente, estado de cargas y limitaciones. |

Si el mapa está bloqueado por políticas institucionales, usen una alternativa geográfica documentada; esto no penaliza el trabajo. Identifiquen UTC en ejes y fechas. Configuren actualización automática en cada página que se use para demostrar cambios. No relacionen arbitrariamente cargas y eventos: las cargas describen ejecuciones, no una dimensión de cada evento.

### Etapa 6. Prueba reproducible
En una base de demostración inicialmente vacía, detengan el modo continuo. Ejecuten preparar_demo() para guardar una captura real y dividirla en lote inicial y lote reservado. Carguen únicamente el inicial. No ejecuten la carga en vivo hasta finalizar esta prueba.

Durante la sustentación: (1) muestren el conteo inicial; (2) carguen el lote reservado; (3) contrasten el aumento con SQL; (4) esperen el refresco automático de Power BI; (5) repitan exactamente el lote y comprueben que el conteo no aumenta y que no hay duplicados. Retiren filtros que oculten los eventos reservados. Identifiquen la prueba como reproducción controlada de datos reales y conserven las fechas originales. Después pueden demostrar el modo continuo.

## 5. Entregables
Entreguen un ZIP Grupo_XX_Observatorio con:
- Informe Grupo_XX_Observatorio.pbix.
- SQL de estructura, vistas y verificaciones, incluyendo aportes del grupo.
- Script R de carga y configuración de ejemplo sin contraseñas.
- Lotes reales usados en la demostración y evidencia de fecha/fuente de descarga.
- README: integrantes, pasos para reproducir, versiones utilizadas, diccionario, definiciones de indicadores, validaciones, tres hallazgos y limitaciones.
- Evidencia breve de la prueba: capturas antes/después y resultados SQL. La evidencia complementa la demostración, no la sustituye.

No entreguen contraseñas ni un archivo de configuración que las contenga. No se exige un PBIX proporcionado por el docente: construirlo es parte del trabajo.

## 6. Evaluación
Cada criterio se califica de 0 a 5. Nota final = suma de nota del criterio × su ponderación.

| Criterio | Peso | Evidencia de logro completo |
|---|---:|---|
| Integración y actualización | 25% | Conexión DirectQuery, carga nueva visible automáticamente y repetición sin duplicados. |
| Organización y calidad | 20% | Clave válida, fechas diferenciadas, faltantes documentados, controles y consultas SQL propias. |
| Análisis e interpretación | 30% | Indicadores verificables, tres hallazgos relevantes, comparaciones justificadas y limitaciones explícitas. |
| Diseño y uso | 15% | Tres páginas legibles, unidades y filtros claros, gráficos pertinentes y navegación coherente. |
| Reproducibilidad y sustentación | 10% | Instrucciones suficientes, archivos completos sin secretos y explicación del flujo por los integrantes. |

Escala orientadora por criterio: 5 = completo y sustentado; 4 = funcional con omisiones menores; 3 = parcial con limitaciones explicadas; 2 = fallas importantes; 1 = evidencia mínima; 0 = sin evidencia. La estética no reemplaza la validación ni la interpretación.

## 7. Lista de comprobación
- PostgreSQL y script activos; conexión local comprobada.
- Diferencia entre fecha del evento, revisión de la fuente y carga comprendida.
- Unidades, UTC, fuente y período visibles.
- Tres indicadores conciliados con SQL.
- Lote reservado listo y no cargado previamente.
- Refresco automático habilitado y filtros de demostración revisados.
- Limitaciones del catálogo y de la ventana móvil documentadas.

## 8. Fuentes oficiales
Consultadas el 22 de septiembre de 2026.
- USGS, formato y feeds: https://earthquake.usgs.gov/earthquakes/feed/v1.0/geojson.php
- USGS, API del catálogo: https://earthquake.usgs.gov/fdsnws/event/1/
- PostgreSQL, descarga: https://www.postgresql.org/download/windows/
- Microsoft, conector PostgreSQL: https://learn.microsoft.com/en-us/power-query/connectors/postgresql
- Microsoft, actualización automática: https://learn.microsoft.com/en-us/power-bi/create-reports/desktop-automatic-page-refresh
