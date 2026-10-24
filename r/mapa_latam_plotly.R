# Mapa de sismos de Latinoamérica con plotly (interactivo)
# Campos en Valores (todos con "No resumir"): latitud, longitud, grupo, magnitud, lugar
# Paquetes: install.packages("plotly")
# Aviso: el visual de R de Power BI muestra solo imágenes estáticas, así que este mapa
# puede no verse allí. Probarlo en RStudio (panel Viewer). Para el informe, usar la versión ggplot2.

# dataset <- data.frame(latitud, longitud)
# dataset <- unique(dataset)

# Pegue o escriba aquí el código de script:


library(plotly)

# Solo Latinoamérica y sin magnitud faltante (no se reemplaza por 0: se omite del mapa)
dataset <- dataset[dataset$grupo != "Resto del mundo" & !is.na(dataset$magnitud), ]

# El orden de los niveles define el orden de dibujo: Colombia queda encima
dataset$grupo <- factor(dataset$grupo, levels = c("Resto de Latinoamérica", "Colombia"))

# Países de paises_latam con incluir = TRUE (códigos ISO-3)
iso <- c("MEX","GTM","BLZ","HND","SLV","NIC","CRI","PAN","COL","VEN","GUY","SUR",
         "ECU","PER","BRA","BOL","PRY","CHL","ARG","URY","CUB","HTI","DOM","JAM",
         "BHS","TTO","BRB","LCA","GRD","VCT","ATG","KNA","DMA")

# sizes = rango en píxeles de los puntos (como en el ejemplo de plotly):
# más pequeño y fino = bajar el segundo valor (ej. c(2, 10)).
fig <- plot_geo(dataset, sizes = c(2, 14))

# Silueta de la región: gris claro con bordes blancos; Colombia en naranja claro
fig <- fig %>% add_trace(
  type = "choropleth", locations = iso, locationmode = "ISO-3",
  z = as.numeric(iso == "COL"), zmin = 0, zmax = 1,
  colorscale = list(c(0, "#E2E8F0"), c(1, "#FED7AA")), showscale = FALSE,
  marker = list(line = list(color = "white", width = 1)),
  hoverinfo = "skip", showlegend = FALSE, inherit = FALSE,
  sizes = c(2, 14)   # imprescindible: plotly toma el rango de tamaños de la primera traza (sin esto falla con "zero_range")
)

# Un punto por sismo: tamaño según magnitud, borde blanco muy fino
fig <- fig %>% add_markers(
  x = ~longitud, y = ~latitud, size = ~magnitud, color = ~grupo,
  colors = c("Resto de Latinoamérica" = "#3B82F6", "Colombia" = "#F97316"),
  hoverinfo = "text",
  text = ~paste0(lugar, "<br>Magnitud ", magnitud),
  marker = list(opacity = 0.8, line = list(color = "white", width = 0.4))
)

fig <- fig %>% layout(
  margin = list(l = 0, r = 0, t = 0, b = 0),
  paper_bgcolor = "rgba(0,0,0,0)",
  legend = list(orientation = "h", x = 0.5, xanchor = "center", y = 0),
  geo = list(
    projection = list(type = "mercator"),
    lonaxis = list(range = c(-118, -32)),   # de México al Caribe oriental
    lataxis = list(range = c(-57, 33.5)),   # de Tierra del Fuego al norte de México
    showframe = FALSE, bgcolor = "rgba(0,0,0,0)",
    showland = FALSE, showcountries = FALSE, showcoastlines = FALSE,
    showocean = FALSE, showlakes = FALSE
  )
)

fig
