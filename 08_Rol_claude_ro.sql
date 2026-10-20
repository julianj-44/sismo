-- Rol de solo lectura para Claude (MCP), separado de pbi_lector (Power BI).
-- Ejecutar en pgAdmin (Query Tool) conectado a la base del proyecto,
-- como postgres o el dueño de las tablas. No guardes la clave real en este archivo.

-- 1) ¿Ya existe? Si devuelve una fila, NO ejecutes el CREATE ROLE (usa el ALTER ROLE para cambiar la clave).
SELECT rolname FROM pg_roles WHERE rolname = 'claude_ro';

-- 2) Crear el rol (solo si no existe). Clave solo con letras y números: si lleva @ # / : la URL del MCP se rompe.
CREATE ROLE claude_ro LOGIN PASSWORD 'CAMBIAR_CLAVE_SOLO_LETRAS_Y_NUMEROS';
-- ALTER ROLE claude_ro PASSWORD 'NUEVA_CLAVE';

-- 3) Permisos: conectar y leer todo el esquema observatorio (tablas y vistas). Sin escritura.
--    Cambia observatorio_sismico por el nombre real de la base (SELECT current_database();).
GRANT CONNECT ON DATABASE observatorio_sismico TO claude_ro;
GRANT USAGE   ON SCHEMA observatorio TO claude_ro;
GRANT SELECT  ON ALL TABLES IN SCHEMA observatorio TO claude_ro;   -- incluye las vistas existentes

-- Que lo que se cree después en el esquema también se pueda leer (aplica a objetos creados por quien ejecuta esto).
ALTER DEFAULT PRIVILEGES IN SCHEMA observatorio GRANT SELECT ON TABLES TO claude_ro;

-- 4) Comprobar que NO puede escribir (debe fallar con "permission denied"):
-- SET ROLE claude_ro;  CREATE TABLE observatorio.prueba (x int);  RESET ROLE;

-- 5) Después, con claude_ro ya creado, pbi_lector puede quedar solo con vistas:
-- REVOKE SELECT ON ALL TABLES IN SCHEMA observatorio FROM pbi_lector;
-- GRANT  SELECT ON observatorio.v_eventos_pais, observatorio.v_cargas, observatorio.v_paises TO pbi_lector;

-- Registrar el MCP con el rol nuevo (PowerShell, DENTRO de la carpeta del proyecto):
--   claude mcp remove postgres -s local
--   claude mcp add --scope local postgres -- cmd /c npx -y @modelcontextprotocol/server-postgres postgresql://claude_ro:TU_CLAVE@localhost:5432/observatorio_sismico
--   claude mcp get postgres      (debe decir Connected)
-- Cierra y vuelve a abrir Claude en la carpeta para que tome el cambio.
