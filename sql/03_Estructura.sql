-- Ejecutar en observatorio_sismico mediante Query Tool de pgAdmin.
CREATE SCHEMA IF NOT EXISTS observatorio;
CREATE TABLE IF NOT EXISTS observatorio.eventos (
 id text PRIMARY KEY,
 fecha_evento timestamptz NOT NULL,
 actualizado_fuente timestamptz NOT NULL,
 lugar text,
 magnitud double precision,
 tipo_magnitud text,
 longitud double precision CHECK (longitud BETWEEN -180 AND 180),
 latitud double precision CHECK (latitud BETWEEN -90 AND 90),
 profundidad_km double precision,
 url text,
 fecha_carga timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS eventos_fecha_idx ON observatorio.eventos(fecha_evento);
CREATE TABLE IF NOT EXISTS observatorio.cargas (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 inicio timestamptz NOT NULL,
 fin timestamptz NOT NULL DEFAULT now(),
 origen text NOT NULL,
 estado text NOT NULL,
 procesados integer NOT NULL,
 afectados integer NOT NULL,
 mensaje text
);
CREATE OR REPLACE VIEW observatorio.v_eventos AS
SELECT id, fecha_evento AT TIME ZONE 'UTC' AS fecha_evento_utc,
 actualizado_fuente AT TIME ZONE 'UTC' AS actualizado_fuente_utc,
 fecha_carga AT TIME ZONE 'UTC' AS fecha_carga_utc,
 (fecha_evento AT TIME ZONE 'UTC')::date AS dia_utc,
 lugar,magnitud,tipo_magnitud,longitud,latitud,profundidad_km,url
FROM observatorio.eventos;
CREATE OR REPLACE VIEW observatorio.v_cargas AS
SELECT id,inicio AT TIME ZONE 'UTC' AS inicio_utc,
 fin AT TIME ZONE 'UTC' AS fin_utc,origen,estado,procesados,afectados,mensaje
FROM observatorio.cargas;


----------------------------------------------------
CREATE TABLE IF NOT EXISTS observatorio.paises_latam (
      nombre_usgs text PRIMARY KEY,
      pais text NOT NULL,
      subregion text NOT NULL,
      incluir boolean NOT NULL DEFAULT true
    );

    INSERT INTO observatorio.paises_latam
      (nombre_usgs, pais, subregion, incluir) VALUES
    ('Brazil','Brasil','América del Sur',true),
    ('Mexico','México','América Central',true),
    ('Colombia','Colombia','América del Sur',true),
    ('Argentina','Argentina','América del Sur',true),
    ('Peru','Perú','América del Sur',true),
    ('Venezuela','Venezuela','América del Sur',true),
    ('Chile','Chile','América del Sur',true),
    ('Guatemala','Guatemala','América Central',true),
    ('Ecuador','Ecuador','América del Sur',true),
    ('Bolivia','Bolivia','América del Sur',true),
    ('Haiti','Haití','Caribe',true),
    ('Dominican Republic','República Dominicana','Caribe',true),
    ('Honduras','Honduras','América Central',true),
    ('Cuba','Cuba','Caribe',true),
    ('Nicaragua','Nicaragua','América Central',true),
    ('Paraguay','Paraguay','América del Sur',true),
    ('El Salvador','El Salvador','América Central',true),
    ('Costa Rica','Costa Rica','América Central',true),
    ('Panama','Panamá','América Central',true),
    ('Uruguay','Uruguay','América del Sur',true),
    ('Jamaica','Jamaica','Caribe',true),
    ('Trinidad and Tobago','Trinidad y Tobago','Caribe',true),
    ('Guyana','Guyana','América del Sur',true),
    ('Suriname','Surinam','América del Sur',true),
    ('Belize','Belice','América Central',true),
    ('Bahamas','Bahamas','Caribe',true),
    ('Barbados','Barbados','Caribe',true),
    ('Saint Lucia','Santa Lucía','Caribe',true),
    ('Grenada','Granada','Caribe',true),
    ('Saint Vincent and the Grenadines',
     'San Vicente y las Granadinas','Caribe',true),
    ('Antigua and Barbuda','Antigua y Barbuda','Caribe',true),
    ('Dominica','Dominica','Caribe',true),
    ('Saint Kitts and Nevis',
     'San Cristóbal y Nieves','Caribe',true),
    ('Puerto Rico','Puerto Rico (dependencia)','Caribe',false),
    ('French Guiana','Guayana Francesa (dependencia)',
     'América del Sur',false)
    ON CONFLICT (nombre_usgs) DO NOTHING;


INSERT INTO observatorio.paises_latam
    (nombre_usgs, pais, subregion, incluir)
    VALUES ('MX','México','América Central',true)
    ON CONFLICT (nombre_usgs) DO NOTHING;

----------------------------------------------------




-- Usuario de lectura: crearlo en pgAdmin con nombre pbi_lector y contraseña propia.
-- Después de crearlo, ejecutar por separado:
GRANT CONNECT ON DATABASE observatorio_sismico TO pbi_lector;
GRANT USAGE ON SCHEMA observatorio TO pbi_lector;
GRANT SELECT ON observatorio.v_eventos, observatorio.v_cargas TO pbi_lector;
