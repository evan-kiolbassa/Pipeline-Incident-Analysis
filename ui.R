library(shiny)
library(leaflet)
library(tidyverse)
library(DT)

navbarPage("Oil Pipeline Incidents 2010-2016", id="main",
           tabPanel("Map", leafletOutput("pimap", height=1000)),
           tabPanel("Pipeline Incidents Summary", 
                    fluidRow(infoBoxOutput('incidentsum')
                    )),
           tabPanel("Environmental/Community Impact", selectizeInput('selected',
                                                          'Select Impact Factor',
                                                          choices= Env.Cat),
                                                                       
           fluidRow(plotOutput("barchart"), height = 300)))
           


