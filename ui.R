library(shiny)
library(leaflet)
library(tidyverse)
library(DT)
library(shinydashboard)

navbarPage("Oil Pipeline Incidents 2010-2016", id="main",
           tabPanel("Map", leafletOutput("pimap", height=1000)),
           tabPanel("Pipeline Incidents Summary", 
                    fluidRow(infoBoxOutput('incidentsum'),
                             infoBoxOutput("netloss"),
                             infoBoxOutput("totalcost"),
                             infoBoxOutput("avgdown")
                    ),
                    fluidRow(plotOutput("cause_loss")),
                    fluidRow(plotOutput("cause.category"))
                    
           ),
           tabPanel("Environmental/Community Impact", selectizeInput('selected',
                                                                     'Select Impact Factor',
                                                                     choices= Env.Cat),
                    
                    fluidRow(plotOutput("barchart"), height = 300)))
           


