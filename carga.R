

#install.packages(c('DBI', 'RPostgres', 'jsonlite', 'httr2'))
Sys.setenv(PGUSER = 'postgres', PGDATABASE = 'observatorio_sismico', PGPORT = '5432')
Sys.setenv(PGPASSWORD = rstudioapi::askForPassword('Contraseña local de PostgreSQL'))
source('04_Carga_USGS.R')

cargar()


