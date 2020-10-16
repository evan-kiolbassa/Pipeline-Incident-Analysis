library(shiny)
library(leaflet)

navbarPage("Location of Oil Pipeline Incidents", id="main",
           tabPanel("Map", leafletOutput("pimap", height=1000)))
           


