# Prueba reproducible (Etapa 6) sobre la base observatorio_demo.
# Ejecutar PASO A PASO (Ctrl+Enter), no con source(): cada paso se comprueba antes del siguiente.
# No modifica r/04_Carga_USGS.R ni r/carga.R. No usar preparar_demo(): datos_demo/ ya existe.
# El directorio de trabajo debe ser la raíz del proyecto (abrir el .Rproj).
#
# Antes de empezar, en pgAdmin y sobre observatorio_demo ya deben estar ejecutados (carpeta sql/):
#   03_Estructura.sql, 06_Vista_eventos_pais.sql, 07_Vistas_paises.sql y 09_Base_demo.sql
# Y el modo continuo (continuar) debe estar detenido.

# ---- PASO 0. Preparar la sesión (apunta a la base DEMO) -----------------------------------
stopifnot(file.exists('r/04_Carga_USGS.R'), file.exists('datos_demo/inicial.json'),
          file.exists('datos_demo/reservado.json'))   # el directorio de trabajo debe ser la carpeta del proyecto
Sys.setenv(PGUSER = 'postgres', PGDATABASE = 'observatorio_demo', PGPORT = '5432')
Sys.setenv(PGPASSWORD = rstudioapi::askForPassword('Contraseña local de PostgreSQL'))
source('r/04_Carga_USGS.R')   # solo define funciones

# Ayudantes de esta prueba
verificar_demo <- function() {   # evita cargar por error en la base real
  if (Sys.getenv('PGDATABASE') != 'observatorio_demo') stop('PGDATABASE no es observatorio_demo.')
  invisible(TRUE)
}
consultar <- function(sql) {
  verificar_demo()
  con <- conectar(); on.exit(DBI::dbDisconnect(con))
  DBI::dbGetQuery(con, sql)
}
contar <- function() consultar(
  'SELECT count(*) AS eventos, count(DISTINCT id) AS ids_unicos FROM observatorio.eventos')
registro <- function() consultar(
  'SELECT id, origen, estado, procesados, afectados, fin_utc FROM observatorio.v_cargas ORDER BY id')

# ---- PASO 1. Comprobar que la base demo está vacía ----------------------------------------
contar()                    # esperado: eventos = 0, ids_unicos = 0
registro()                  # esperado: 0 filas

# ---- PASO 2. Carga inicial ----------------------------------------------------------------
verificar_demo()
cargar('datos_demo/inicial.json')   # mensaje esperado: Procesados: 9882; insertados o revisados: 9882
contar()                            # esperado: 9882 y 9882
# >> Abrir la copia del informe apuntando a observatorio_demo y tomar la captura "antes"
#    (Evidencia/1_antes.png) con el conteo inicial.

# ---- PASO 3. Carga del lote reservado (esto es lo que se muestra en vivo) ------------------
verificar_demo()
cargar('datos_demo/reservado.json') # esperado: Procesados: 20; insertados o revisados: 20
contar()                            # esperado: 9902 y 9902
# >> Esperar el refresco automático de Power BI (máx. 1 min) y tomar la captura "después".

# ---- PASO 4. Repetir exactamente la misma carga (no debe duplicar) -------------------------
verificar_demo()
cargar('datos_demo/reservado.json') # esperado: Procesados: 20; insertados o revisados: 0
contar()                            # esperado: 9902 y 9902 (no cambia)
registro()                          # esperado: 3 cargas ok con afectados 9882, 20 y 0

# ---- PASO 5. Volver al carril real -------------------------------------------------------
Sys.setenv(PGDATABASE = 'observatorio_sismico')   # ya NO se puede usar verificar_demo()
Sys.getenv('PGDATABASE')                          # debe decir observatorio_sismico
# Modo continuo (opcional, al final de la sustentación):
#   cargar()
#   continuar(300)    # detener con Esc/Stop
# Al terminar: Sys.unsetenv('PGPASSWORD')
