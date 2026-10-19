# Instalación y ejecución local

## 1. Preparar un computador Windows por grupo
Descarguen PostgreSQL desde https://www.postgresql.org/download/windows/ e instalen servidor y pgAdmin. Conserven la contraseña elegida para postgres y el puerto (normalmente 5432). Instalen R desde https://cran.r-project.org/ y RStudio Desktop desde https://posit.co/download/rstudio-desktop/. Instalen Power BI Desktop desde la fuente oficial de Microsoft. No se necesita abrir el puerto a internet ni configurar gateway para esta ejecución local.

## 2. Crear base y estructura
En pgAdmin, conecten al servidor local. En Databases → Create → Database creen observatorio_sismico. Abran Query Tool sobre ESA base, abran 03_Estructura.sql y ejecútenlo. El script no crea la base: ese paso se realiza previamente en la interfaz.

Para Power BI creen un Login/Group Role llamado pbi_lector, activen Can login y definan una contraseña propia. Ejecuten después las tres sentencias GRANT que aparecen comentadas al final del SQL, quitando los prefijos --. No otorguen permisos de escritura a este usuario.

## 3. Preparar R
Descompriman el paquete. En RStudio creen un proyecto en esta carpeta (File → New Project → Existing Directory). En la consola:

```r
install.packages(c('DBI', 'RPostgres', 'jsonlite', 'httr2'))
Sys.setenv(PGUSER = 'postgres', PGDATABASE = 'observatorio_sismico', PGPORT = '5432')
Sys.setenv(PGPASSWORD = rstudioapi::askForPassword('Contraseña local de PostgreSQL'))
source('04_Carga_USGS.R')
```

La contraseña se pide en un cuadro y permanece en el entorno de la sesión; no la escriban en el script ni la entreguen. Al terminar pueden ejecutar Sys.unsetenv('PGPASSWORD'). Usar postgres se limita al arranque didáctico local; como mejora pueden crear un usuario de carga con permisos solo sobre estas tablas y su secuencia.

## 4. Preparar la demostración antes de cargar en vivo
Con la tabla eventos vacía:

```r
preparar_demo()
cargar('datos_demo/inicial.json')
```

Se descargan datos reales al ejecutar preparar_demo(); el ZIP no trae una captura precargada. Conserven ambos JSON y procedencia.txt para reproducir sin internet. Si ya hicieron cargas en vivo, creen una NUEVA base vacía observatorio_demo, ejecuten allí el SQL y cambien PGDATABASE a observatorio_demo. No borren su trabajo anterior. En esa base reotorguen los permisos de lectura (CONNECT sobre observatorio_demo y permisos de esquema/vistas).

## 5. Conectar Power BI
Obtener datos → Base de datos PostgreSQL. Servidor localhost:5432, base observatorio_sismico (o observatorio_demo si la crearon), modo DirectQuery, autenticación de base con pbi_lector. Seleccionen observatorio.v_eventos y observatorio.v_cargas. Mantengan ambas en DirectQuery. Las contraseñas de PostgreSQL son locales; no son las de Microsoft.

Si aparece una advertencia de cifrado, verifiquen que el destino sea realmente localhost. Para esta prueba en el mismo equipo puede aceptarse la conexión local sin cifrado; no trasladen esa configuración a un servidor remoto.

Construyan una tarjeta con el conteo de id y comparen con 05_Verificaciones.sql. En formato de página busquen Actualización de página, habiliten intervalo fijo de 1 minuto. La opción requiere DirectQuery. Si no aparece, revisen modo de almacenamiento y versión de Desktop. Mantengan abierta la página durante la prueba.

Medidas iniciales orientativas (ajusten los nombres al modelo; el separador puede variar según configuración regional):

```dax
Eventos = COUNTROWS(v_eventos)
Magnitud maxima = MAX(v_eventos[magnitud])
Ultimo evento UTC = MAX(v_eventos[fecha_evento_utc])
Ultima carga exitosa UTC = CALCULATE(MAX(v_cargas[fin_utc]), v_cargas[estado] = "ok")
```

Categoricen latitud y longitud correctamente y eviten su suma. Si no está habilitado el mapa, usen otra visualización geográfica documentada.

## 6. Demostrar y verificar
Con el informe abierto y el inicial ya cargado:

```r
cargar('datos_demo/reservado.json')
# Esperen la actualización de Power BI y registren el aumento.
cargar('datos_demo/reservado.json')
# El conteo no aumenta; afectados debe ser 0.
```

No ejecuten continuar() antes de terminar la prueba: cargaría también los eventos reservados. El script no elimina eventos ni modifica fechas originales. Usen 05_Verificaciones.sql y registren resultados con los mismos filtros del tablero.

## 7. Carga en vivo
Después de demostrar los lotes:

```r
cargar()        # Una consulta a la fuente
continuar(300) # Repite; detener con Esc/Stop
```

El computador debe permanecer encendido, PostgreSQL activo y R ejecutándose. Power BI debe estar abierto para observar cambios. Una carga puede procesar datos sin encontrar eventos nuevos: afectados=0 no significa error. Si la descarga falla, las visualizaciones conservarán los datos previos; la página de calidad debe mostrarlo.

## 8. Solución de problemas
- Connection refused: comprobar servicio PostgreSQL y puerto.
- Password authentication failed: comprobar usuario/contraseña de PostgreSQL.
- Relation does not exist: ejecutar estructura en la misma base configurada en R/Power BI.
- Permission denied: comprobar GRANT de vistas y USAGE del esquema.
- No cambia el tablero: comprobar carga exitosa, DirectQuery, intervalo, página activa y filtros.
- Al abrir PBIX en otro equipo: reconstruir la base y volver a configurar credenciales.

## Alcance de la validación del paquete
El material y la coherencia entre campos fueron revisados. No se ejecutó aquí la integración R–PostgreSQL–Power BI porque este entorno no dispone de R, PostgreSQL ni Power BI Desktop. El primer hito es una prueba de instalación y conexión en el computador Windows del grupo.
