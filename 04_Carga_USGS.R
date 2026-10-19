# Ejecutar desde la carpeta del proyecto. Este archivo solo define funciones.
# install.packages(c('DBI', 'RPostgres', 'jsonlite', 'httr2'))
paquetes <- c('DBI', 'RPostgres', 'jsonlite', 'httr2')
stopifnot(all(vapply(paquetes, requireNamespace, logical(1), quietly = TRUE)))
feed <- 'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson'
conectar <- function() {
  if (!nzchar(Sys.getenv('PGPASSWORD'))) stop('Configure PGPASSWORD en la sesión de R.')
  DBI::dbConnect(RPostgres::Postgres(), host = 'localhost',
    port = as.integer(Sys.getenv('PGPORT', '5432')),
    dbname = Sys.getenv('PGDATABASE', 'observatorio_sismico'),
    user = Sys.getenv('PGUSER', 'postgres'), password = Sys.getenv('PGPASSWORD'))
}
leer_feed <- function() {
  r <- httr2::request(feed)
  r <- httr2::req_timeout(r, 60)
  r <- httr2::req_retry(r, max_tries = 3)
  r <- httr2::req_perform(r)
  x <- jsonlite::fromJSON(httr2::resp_body_string(r), simplifyVector = FALSE)
  if (!identical(x$type, 'FeatureCollection')) stop('Respuesta inesperada del USGS.')
  x
}
escalar <- function(x, numerico = FALSE) {
  if (is.null(x) || length(x) != 1) return(if (numerico) NA_real_ else NA_character_)
  if (numerico) as.numeric(x) else as.character(x)
}
fecha <- function(x) as.POSIXct(escalar(x, TRUE) / 1000, origin = '1970-01-01', tz = 'UTC')
normalizar <- function(x) {
  filas <- lapply(x$features, function(f) {
    p <- f$properties
    if (!identical(p$type, 'earthquake')) return(NULL)
    if (length(f$geometry$coordinates) < 3) stop('Coordenadas incompletas.')
    data.frame(id = escalar(f$id), fecha_evento = fecha(p$time),
      actualizado_fuente = fecha(p$updated), lugar = escalar(p$place),
      magnitud = escalar(p$mag, TRUE), tipo_magnitud = escalar(p$magType),
      longitud = escalar(f$geometry$coordinates[[1]], TRUE),
      latitud = escalar(f$geometry$coordinates[[2]], TRUE),
      profundidad_km = escalar(f$geometry$coordinates[[3]], TRUE),
      url = escalar(p$url), stringsAsFactors = FALSE)
  })
  filas <- Filter(Negate(is.null), filas)
  if (!length(filas)) return(data.frame())
  d <- do.call(rbind, filas)
  if (anyNA(d$id) || any(!nzchar(d$id)) || anyNA(d$fecha_evento) || anyNA(d$actualizado_fuente))
    stop('Identificador o fechas obligatorias ausentes.')
  d <- d[order(d$actualizado_fuente, decreasing = TRUE), ]
  d[!duplicated(d$id), ]
}
cargar <- function(archivo = NULL) {
  inicio <- Sys.time()
  con <- conectar()
  on.exit(DBI::dbDisconnect(con))
  origen <- if (is.null(archivo)) feed else basename(archivo)
  tryCatch({
    x <- if (is.null(archivo)) leer_feed() else jsonlite::fromJSON(archivo, simplifyVector = FALSE)
    d <- normalizar(x)
    afectados <- DBI::dbWithTransaction(con, {
      n <- 0L
      if (nrow(d)) {
        DBI::dbWriteTable(con, 'lote_usgs', d, temporary = TRUE, overwrite = TRUE)
        n <- DBI::dbExecute(con, "
          INSERT INTO observatorio.eventos AS e
          (id,fecha_evento,actualizado_fuente,lugar,magnitud,tipo_magnitud,longitud,latitud,profundidad_km,url)
          SELECT id,fecha_evento,actualizado_fuente,lugar,magnitud,tipo_magnitud,longitud,latitud,profundidad_km,url
          FROM lote_usgs
          ON CONFLICT (id) DO UPDATE SET
            fecha_evento=EXCLUDED.fecha_evento, actualizado_fuente=EXCLUDED.actualizado_fuente,
            lugar=EXCLUDED.lugar, magnitud=EXCLUDED.magnitud,tipo_magnitud=EXCLUDED.tipo_magnitud,
            longitud=EXCLUDED.longitud,latitud=EXCLUDED.latitud,profundidad_km=EXCLUDED.profundidad_km,
            url=EXCLUDED.url,fecha_carga=now()
          WHERE EXCLUDED.actualizado_fuente > e.actualizado_fuente")
      }
      DBI::dbExecute(con,
        "INSERT INTO observatorio.cargas (inicio,origen,estado,procesados,afectados) VALUES ($1,$2,'ok',$3,$4)",
        params = list(inicio, origen, nrow(d), n))
      n
    })
    message('Procesados: ', nrow(d), '; insertados o revisados: ', afectados)
    invisible(afectados)
  }, error = function(e) {
    try(DBI::dbExecute(con,
      "INSERT INTO observatorio.cargas (inicio,origen,estado,procesados,afectados,mensaje) VALUES ($1,$2,'error',0,0,$3)",
      params = list(inicio, origen, conditionMessage(e))), silent = TRUE)
    stop(conditionMessage(e), call. = FALSE)
  })
}
preparar_demo <- function(carpeta = 'datos_demo', reserva = 20L) {
  if (dir.exists(carpeta)) stop('La carpeta ya existe; elija otra para conservar la captura anterior.')
  x <- leer_feed()
  f <- Filter(function(z) identical(z$properties$type, 'earthquake'), x$features)
  ids <- vapply(f, function(z) escalar(z$id), character(1))
  if (anyDuplicated(ids)) stop('Identificadores repetidos en la captura.')
  if (length(f) <= reserva || reserva < 1) stop('Tamaño de reserva incompatible con la captura.')
  dir.create(carpeta, recursive = TRUE)
  guardar <- function(items, nombre) {
    y <- list(type = 'FeatureCollection', features = items)
    jsonlite::write_json(y, file.path(carpeta, nombre), auto_unbox = TRUE, pretty = TRUE, digits = NA)
  }
  guardar(f[-seq_len(reserva)], 'inicial.json')
  guardar(f[seq_len(reserva)], 'reservado.json')
  writeLines(c(paste('Fuente:', feed), paste('Descarga UTC:', format(Sys.time(), tz='UTC')),
    paste('Inicial:', length(f) - reserva), paste('Reservado:', reserva),
    'Reproducción de datos reales; fechas originales conservadas.'), file.path(carpeta, 'procedencia.txt'))
  message('Lotes guardados. Cargar primero inicial.json en una base vacía.')
}
continuar <- function(intervalo = 300) {
  stopifnot(is.numeric(intervalo), length(intervalo) == 1, intervalo >= 60)
  message('Modo continuo. Detener con Esc/Stop en RStudio o Ctrl+C en consola.')
  repeat {
    tryCatch(cargar(), error = function(e) message('Carga fallida: ', conditionMessage(e)))
    Sys.sleep(intervalo)
  }
}
