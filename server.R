#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(DT)
library(shiny)
library(leaflet)
library(tidyverse)
library(RColorBrewer)
require(Hmisc)

function(input, output) {
  pal <- colorFactor(pal = c("#1b9e77", "#d95f02", "#7570b3"), 
                     domain = unique(pipeline.df$Cause.Category))
  # create the leaflet map  
  output$pimap <- renderLeaflet({
    leaflet(pipeline.df) %>% 
      addCircles(lng = ~Accident.Longitude, lat = ~Accident.Latitude) %>% 
      addTiles() %>%
      addCircleMarkers(data = pipeline.df, lat =  ~Accident.Latitude, 
                       lng =~Accident.Longitude, 
                       radius = 3,   
                       color = ~pal(Cause.Category),
                       stroke = FALSE, fillOpacity = 0.8) %>%
      addLegend(pal = pal,values=pipeline.df$Cause.Category,opacity=1, 
                na.label = "Not Available") %>%
      addEasyButton(easyButton(
        icon="fa-crosshairs", title="ME",
        onClick=JS("function(btn, map){ map.locate({setView: true}); }")))
  })
  
}