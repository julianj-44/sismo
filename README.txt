El usuario objetivo es un equipo de seguimiento sísmico interesado en
Colombia, que necesita ubicar lo que registra el USGS en el país dentro
del panorama de América Latina y el Caribe, explorar su distribución
geográfica y temporal y conocer la actualidad de la información. El
tablero responde tres preguntas: (1) cuántos sismos y de qué magnitud
registró el USGS en la región y qué lugar ocupa Colombia; (2) cómo se
comportan los sismos registrados en Colombia, en frecuencia diaria,
magnitud y profundidad, frente al resto de la región; y (3) qué tan
actual y completa es la información cargada. Los datos provienen del
feed de todos los eventos de los últimos 30 días del USGS (descargas:
18 de octubre de 2026, 18:25 UTC, y 20 de octubre de 2026, 16:43 UTC),
conservando solo los de tipo earthquake. La base acumula los eventos de
ambas cargas: el informe cubre del 18 de septiembre al 20 de octubre de
2026 (UTC), 10.514 eventos, y se limita a 34 países y territorios de
América Latina y el Caribe, identificados por el texto del
campo lugar; Colombia es el país de referencia y se resalta en los
gráficos. Las comparaciones entre países usan magnitud de 4.5 o más,
porque el catálogo registra de forma desigual los sismos pequeños entre
regiones.

PÁGINAS DEL INFORME (contenido mínimo)

Página 1. Panorama
  Conteo de eventos, magnitud máxima, último evento, mapa o alternativa
  geográfica y filtros por período, magnitud y profundidad.

Página 2. Análisis
  Evolución temporal, distribución de magnitud y profundidad,
  comparación argumentada de subconjuntos y tres hallazgos.

Página 3. Calidad y actualidad
  Faltantes, última carga exitosa, evento más reciente, estado de cargas
  y limitaciones.

DICCIONARIO DE DATOS: VALORES NEGATIVOS

magnitud (adimensional) y profundidad_km (km) pueden ser negativas. Son
valores válidos y dos fenómenos distintos; no se reemplazan por 0 ni se
descartan.

  magnitud negativa
    La escala de magnitud es logarítmica y no tiene valor mínimo: un
    sismo cuya amplitud es mil veces menor que la de uno de magnitud 2
    tiene magnitud -1. Son microsismos que las personas no sienten. No
    tiene relación con el nivel del mar. En los datos cargados hay 479
    eventos con magnitud negativa (4,6 % de 10.514); el mínimo es -1,29.

  profundidad negativa
    USGS mide la profundidad hacia abajo desde un nivel de referencia
    (el geoide WGS84, el nivel del mar o la elevación media de las
    estaciones, según la red sísmica que reporta el evento). Si el
    epicentro queda por encima de esa referencia, por ejemplo en
    terreno elevado o volcánico, la profundidad es negativa. También
    puede ser un artefacto de la poca resolución de un sismo muy
    superficial. No significa que el sismo ocurra en el aire. En los
    datos cargados hay 219 eventos (2,1 %), con un mínimo de -3,4 km;
    218 son del grupo "Resto del mundo" (Alaska 79, Hawái 50,
    California 43, Washington 23, Utah 13 y otros) y 1 es de México
    (52 km SSW de Maneadero, B.C.; -0,4 km). Ninguno es de Colombia. La
    magnitud promedio de los 219 es 0,83. En los tramos de profundidad
    se incluyen en "Menos de 10 km".

  No se debe inferir una variable de la otra. Cruzadas en los 10.514
  eventos:

                          profundidad >= 0    profundidad negativa
    magnitud >= 0                9.876                 159
    magnitud negativa              419                  60

  Coinciden en pocos casos porque los microsismos solo los detectan
  redes locales densas, y esas redes están en zonas volcánicas o
  montañosas donde también aparecen profundidades negativas. Esto
  refuerza que las magnitudes promedio de grupos distintos no son
  comparables (por eso las comparaciones entre países usan magnitud de
  4,5 o más).

  Fuentes (USGS):
    https://www.usgs.gov/faqs/how-can-earthquake-have-a-negative-magnitude
    https://www.usgs.gov/faqs/what-reference-datum-used-earthquake-depths
    https://www.usgs.gov/faqs/what-does-it-mean-earthquake-occurred-a-depth-0-km-how-can-earthquake-have-a-negative-depth
    https://www.usgs.gov/center-news/volcano-watch-why-do-some-earthquakes-have-negative-depths
