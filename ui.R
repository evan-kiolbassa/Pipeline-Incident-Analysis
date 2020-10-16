library(shiny)
library(leaflet)
library(tidyverse)

navbarPage("Location of Oil Pipeline Incidents", id="main",
           tabPanel("Map", leafletOutput("pimap", height=1000)),
           tabPanel("Environmental/Community Impact", selectizeInput('selected',
                                                          'Select Impact Factor',
                                                          choices= Env.Cat),
                                                                       
           fluidRow(plotOutput("barchart"), height = 300)))
           


