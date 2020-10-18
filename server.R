
library(shinydashboard)
library(DT)
library(shiny)
library(leaflet)
library(tidyverse)
library(RColorBrewer)
require(Hmisc)

function(input, output) {
  # Generating a color palette based on Cause.Category
  pal <- colorFactor(pal = c("#1b9e77", "#d95f02", "#7570b3"), 
                     domain = unique(pipeline.df$Cause.Category))
  # creating Interactive Leaflet map visualizing pipeline incidents by
  # Cause.Category
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
  
  # Generating a bar chart visualizing environmental/community impact factors
  # by year
  output$barchart <- renderPlot({
    ggplot(env.comm.impact, aes(x = Accident.Year, 
                                y = eval(as.symbol(input$selected)))) +
      geom_bar(data = env.comm.impact ,stat = 'identity', 
               aes(x = Accident.Year, y = eval(as.symbol(input$selected)))) +
      ylab(input$selected) + ggtitle(input$selected,"by Year")}
  )
  
  output$incidentsum = renderInfoBox({
    sum_incidents <- length(pipeline.df$Report.Number)
    infoBox("Total Incidents:", sum_incidents, icon = icon("newspaper"), 
            fill = TRUE)
  })
  
  output$netloss = renderInfoBox({
    sum_netloss <- sum(pipeline.df$Net.Loss.Barrels)
    infoBox("Net Loss of Barrels:", sum_netloss, icon = icon("newspaper"), 
            fill = TRUE)
  })
  
  output$totalcost = renderInfoBox({
    sum_cost <- sum(pipeline.df$All.Costs) / 1000000
    infoBox("Total Cost (Millions):", round(sum_cost, 2), 
            icon = icon("newspaper"), 
            fill = TRUE)
  })
  
  output$avgdown = renderInfoBox({
    mean_down <- mean(shutdown.df$Down.Time)
    infoBox("Avg Shutdown Time (days):", round(mean_down, 2), 
            icon = icon("newspaper"), 
            fill = TRUE)
  })
  
  output$expcount = renderInfoBox({
    exp_count <- length(pipeline.df[pipeline.df$Liquid.Explosion == "YES",
                                 "Liquid.Explosion"])
    infoBox("Number of Explosion Incidents:", exp_count, 
            icon = icon("newspaper"), 
            fill = TRUE)
  })
  
  output$avgcost = renderInfoBox({
    avg_cost <- mean(pipeline.df$All.Costs, na.rm = T)
    infoBox("Average Incident Cost (USD):", round(avg_cost, 2), 
            icon = icon("newspaper"), 
            fill = TRUE)
  })
  
  output$netlossmap <- renderPlot({
    ggplot(data = usa.map, aes(x = long, y = lat)) +
      geom_polygon(aes(group = group, fill = region),fill = "white", 
                   color = "black") +
      geom_point(data = map.viz.df, aes(x = long, y = lat, 
                                        size = Net.Loss.Barrels), color = "red") +
      xlab("") +
      ylab("") +
      theme(panel.grid = element_blank(),
            axis.title = element_blank(),
            axis.text = element_blank(),
            axis.ticks.y = element_blank(),
            axis.ticks.x = element_blank(),
            panel.background = element_blank()) +
      coord_map(xlim = c(-125, -65), ylim = c(26, 48)) + 
      ggtitle("Net Loss in Barrels in Continental U.S")
  })
  
  output$cause_loss <- renderPlot({
    
    ggplot(pipeline.df, aes(x = Net.Loss.Barrels, 
                            y = All.Costs)) +
      geom_point() + geom_smooth(method = "lm") + scale_x_log10() +
      scale_y_log10() + ggtitle("Log Scale Scatterplot of All.Costs vs Net Barrels Lost")
    
  })
  
  output$cause.category <- renderPlot({
    ggplot(pipeline.df, aes(x = Cause.Category)) +
      geom_bar() + ggtitle("Frequency of Pipeline Incident Causes") + coord_flip()
  })
  
  output$cost_year <- renderPlot({
    ggplot(all.costs.year, aes(x = Accident.Year, y = Cost.Year.Millions)) +
      geom_bar(stat = 'identity')
  })
  
  output$cause.avg.cost <- renderPlot({
    ggplot(cause.costs, aes(x = Cause.Category, y = Avg.Cost)) +
      geom_bar(stat = 'identity') + coord_flip()
  })
  
  output$operator_pie <- renderPlot({
    ggplot(operator.costs.year, aes(x = "",y = All.Costs / 1000000, fill = Operator.Name)) +
      geom_bar(stat = "identity") + coord_polar("y") + theme_minimal()+
      theme_void() + scale_fill_brewer(palette = "Paired") + 
      ggtitle("Pie Chart of Top Ten Operators Affected by Pipeline Incidents")
  })
  
}
