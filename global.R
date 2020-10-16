# Loading libraries

library(tidyverse)
library(maps)
library(RColorBrewer)
library(maptools)
library(rgeos)
library(ggmap)
library(rgdal)
library(ggthemes)
suppressPackageStartupMessages(library(googleVis))
suppressPackageStartupMessages(library(ggmap))
# Reading in the dataframe
pipeline.df <- read_csv("Pipeline_Incidents.csv")
# Checking the structure and summary of the data frame
summary(pipeline.df)
str(pipeline.df)
colnames(pipeline.df)

# All of the column titles have spaces. Replacing blank spaces with periods
colnames(pipeline.df) <- str_replace_all(colnames(pipeline.df), " ", ".")
colnames(pipeline.df)

# Removing "/" characters from column names
colnames(pipeline.df) <- str_replace_all(colnames(pipeline.df), "/", ".")
colnames(pipeline.df)

# Removal of parentheses from column names
colnames(pipeline.df) <- gsub("[()]", "", colnames(pipeline.df))
colnames(pipeline.df)

# Converting columns containing date information from character objects
# to date objects
pipeline.df$Accident.Date.Time <- as.Date(pipeline.df$Accident.Date.Time, 
                                          "%m/%d/%Y")
pipeline.df$Shutdown.Date.Time <- as.Date(pipeline.df$Shutdown.Date.Time, 
                                          "%m/%d/%Y")
pipeline.df$Restart.Date.Time <- as.Date(pipeline.df$Restart.Date.Time,
                                         "%m/%d/%Y")
pipeline.df$Accident.Year <- as.character(pipeline.df$Accident.Year)




# 2017 has few data points. Removing 2017
pipeline.df <- pipeline.df %>%
  filter(Accident.Year != 2017)

# What is the total cost per year associated with pipeline incidents?
all.costs.year <- pipeline.df %>%
  select(Accident.Year, All.Costs) %>%
  group_by(Accident.Year) %>%
  summarise(Cost.Year.Millions = sum(All.Costs,na.rm = T)/ 1000000, )

all.costs.year

cost.cat <- pipeline.df %>%
  select(Public.Private.Property.Damage.Costs:All.Costs)

cost.cat <- colnames(cost.cat)

# What is the general trend of costs per yer?

ggplot(pipeline.df, aes(x = Accident.Date.Time, y = All.Costs)) + 
  geom_smooth() + ylab("Total Cost in Millions") + xlab("Accident Year") +
  ggtitle("Pipeline Incident Cost Trend from 2010 to 2016") 
  
# What is the total cost per year for each operator?
length(unique(pipeline.df$Operator.Name))

# There are a total of 229 unique operators in this data set
# Need to focus on the top 20 operators for visualization aesthetics

# Selecting the top 20 operators by total cost
top_20_operators <- pipeline.df %>%
  select(Operator.Name, All.Costs) %>%
  group_by(Operator.Name) %>%
  summarise(total.cost = sum(All.Costs)) %>%
  arrange(desc(total.cost)) %>%
  select(Operator.Name) %>%
  head(20)

# Computing the total costs, total down time,
# and net loss per year of product for the top 20 operators
operator.costs.year <- pipeline.df %>%
  subset(pipeline.df$Operator.Name %in% top_20_operators$Operator.Name) %>%
  select(Operator.Name, All.Costs, Accident.Year, Shutdown.Date.Time,
         Restart.Date.Time, Net.Loss.Barrels) %>%
  group_by(Operator.Name, Accident.Year) %>%
  summarise(Cost.Year.Millions = sum(All.Costs / 1000000), 
            Down.Time = sum(Restart.Date.Time -
                            Shutdown.Date.Time, 
                            na.rm = T),
            Total.Net.Loss.Barrels = sum(Net.Loss.Barrels, na.rm = T))
operator.costs.year

# What impact do pipeline incidents have on surrounding communities
# and environments per year?

# Summing up community and environmental impact factors

env.comm.impact <- pipeline.df %>%
  select(Accident.Year, All.Injuries, All.Fatalities,
         Public.Private.Property.Damage.Costs, Public.Evacuations,
         Environmental.Remediation.Costs) %>%
  group_by(Accident.Year) 
env.comm.impact

Env.Cat <- colnames(env.comm.impact)[-1]


# What states are most heavily impacted by pipeline incidents? What is the net
# loss in barrels per state?
incident.states <- pipeline.df %>%
  select(Accident.State, Net.Loss.Barrels) %>%
  group_by(Accident.State) %>%
  summarise(Total.Incidents = sum(length(Accident.State)), 
            Total.Loss.Barrels = sum(Net.Loss.Barrels)) %>%
  arrange(desc(Total.Incidents))
incident.states

# Manipulating data for U.S Density Map Visualization
map.viz.df <- pipeline.df %>%
  select(Net.Loss.Barrels, Accident.Latitude, Accident.Longitude, 
         Pipeline.Location) %>%
  filter(Pipeline.Location == "ONSHORE")
  colnames(map.viz.df) <- c("Net.Loss.Barrels", "lat", "long", 
                            "Pipeline.Location")


usa.map <- map_data("state")

ggplot(data = usa.map, aes(x = long, y = lat)) +
  geom_polygon(aes(group = group, fill = region),fill = "white", 
               color = "black") +
  geom_point(data = map.viz.df, aes(x = long, y = lat, 
                                    size = Net.Loss.Barrels) 
             ) +
  #geom_density2d(data = map.viz.df, aes(x = long, y = lat), 
                 #color = "black") +
  xlab("") +
  ylab("") +
  theme(panel.grid = element_blank(),
        axis.title = element_blank(),
        axis.text = element_blank(),
        axis.ticks.y = element_blank(),
        axis.ticks.x = element_blank(),
        panel.background = element_blank()) +
  coord_map(xlim = c(-125, -65), ylim = c(26, 48)) + 
  ggtitle("Two Dimensional Density Plot of Pipeline Incidents") 

# What are the most frequent causes of pipeline incidents?
# Summation of causes
cause.df <- pipeline.df %>%
  select(Cause.Category) %>%
  group_by(Cause.Category) %>%
  summarise(Frequency = sum(length(Cause.Category))) %>%
  arrange(desc(Frequency))
cause.df

# It is clear that equipment failure is the number 1 cause of pipeline incidents.
# Let's calculate the total cost of each cause category

cause.costs <- pipeline.df %>%
  select(Cause.Category,All.Costs) %>%
  group_by(Cause.Category) %>%
  summarise(Total.Cost = sum(All.Costs)) %>%
  arrange(desc(Total.Cost))

cause.costs



