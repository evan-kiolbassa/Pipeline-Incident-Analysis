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
                             infoBoxOutput("avgdown"),
                             infoBoxOutput("expcount"),
                             infoBoxOutput("avgcost")),
                    fluidRow(plotOutput("cost_year")),
                    fluidRow(plotOutput("cost_dist")),
                    fluidRow(plotOutput("equip_dist")),
                    fluidRow(plotOutput("cause_loss")),
                    fluidRow(plotOutput("netlossmap")),
                    fluidRow(plotOutput("cause.category")),
                    fluidRow(plotOutput("cause.avg.cost")),
                    fluidRow(plotOutput("equip.sub")),
                    fluidRow(plotOutput("corr.sub")),
                    
           ),
           tabPanel("Pipeline Operator Summary",
                    fluidRow(infoBoxOutput("number_ops")),
                    fluidRow(plotOutput("operator_pie")),
                    fluidRow(DT::dataTableOutput("optable"))),
           tabPanel("Environmental/Community Impact", 
                    selectizeInput('selected',
                    'Select Impact Factor',
                     choices= Env.Cat),
                    
                    fluidRow(plotOutput("barchart"), height = 300)),
           tabPanel("Pipeline Incident Data",
                    fluidRow(DT::dataTableOutput("pipeline"))))
           
# Github repository https://github.com/evan-kiolbassa/Shiny-Project

