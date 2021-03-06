# Loading libraries
library(openair)
library(shinydashboard)
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


# Removing "/" characters from column names
colnames(pipeline.df) <- str_replace_all(colnames(pipeline.df), "/", ".")


# Removal of parentheses from column names
colnames(pipeline.df) <- gsub("[()]", "", colnames(pipeline.df))


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
  summarise(Cost.Year.Millions = sum(All.Costs,na.rm = T)/ 1e6, )

all.costs.year


# Creating a dataframe with no null values in the shut down slots
shutdown.df <- pipeline.df %>%
  filter(Pipeline.Shutdown == "YES") %>%
  mutate(Down.Time = Restart.Date.Time - Shutdown.Date.Time) %>%
  select(All.Costs, Down.Time, Shutdown.Date.Time, Restart.Date.Time) %>%
  filter(Down.Time > 0) %>%
  drop_na() 


# There are a total of 229 unique operators in this data set
# Need to focus on the top 10 operators for visualization aesthetics

# Selecting the top 10 operators by cost associated with equipment failure
top_10_operators <- pipeline.df %>%
  filter(Cause.Category == "MATERIAL/WELD/EQUIP FAILURE") %>%
  group_by(Operator.Name) %>%
  summarise(failure.cost = sum(All.Costs)) %>%
  arrange(desc(failure.cost)) %>%
  head(10)

# Creating a data frame summarizing key incident indicators
operator.summary <- pipeline.df %>%
  group_by(Operator.Name) %>%
  summarise(Cost.Millions = round(sum(All.Costs / 1e6), 2), 
  Down.Time.Days = sum(Restart.Date.Time -
                  Shutdown.Date.Time, 
                na.rm = T),
  Total.Net.Loss.Barrels = sum(Net.Loss.Barrels, na.rm = T),
  Total.Equipment.Failure.Incidents = 
    length(Cause.Category == "MATERIAL/WELD/EQUIP FAILURE")) %>%
  arrange(desc(Cost.Millions))

# Calculating the cost of equipment failure per operator
operator.material.failure <- pipeline.df %>%
  filter(Cause.Category == "MATERIAL/WELD/EQUIP FAILURE") %>%
  group_by(Operator.Name) %>%
  summarise(Equipment.Failure.Costs.Millions = round(sum(All.Costs / 1e6), 2))

# Combining the operator.summary and operator.material.failure data frames
operator.summary <- inner_join(operator.summary, operator.material.failure) %>%
  arrange(desc(Equipment.Failure.Costs.Millions))

# Extracting the top 10 rows for use in pie chart
top.10.operators <- head(operator.summary, 10)
  


# What impact do pipeline incidents have on surrounding communities
# and environments per year?

# Summing up community and environmental impact factors

env.comm.impact <- pipeline.df %>%
  select(Accident.Year, All.Injuries, All.Fatalities,
         Public.Private.Property.Damage.Costs, Public.Evacuations,
         Environmental.Remediation.Costs) %>%
  group_by(Accident.Year) 
env.comm.impact

# Extracting column names for selectize input function
Env.Cat <- colnames(env.comm.impact)[-1]


# Manipulating data for U.S Barrel Loss Map Visualization
map.viz.df <- pipeline.df %>%
  select(Net.Loss.Barrels, Accident.Latitude, Accident.Longitude, 
         Pipeline.Location) %>%
  filter(Pipeline.Location == "ONSHORE")
  colnames(map.viz.df) <- c("Net.Loss.Barrels", "lat", "long", 
                            "Pipeline.Location")

# What are the most frequent causes of pipeline incidents?
# Summation of causes
cause.df <- pipeline.df %>%
  select(Cause.Category) %>%
  group_by(Cause.Category) %>%
  summarise(Frequency = sum(length(Cause.Category))) %>%
  arrange(desc(Frequency))
cause.df

# It is clear that equipment failure is the number 1 cause of pipeline incidents.
# Let's calculate the average cost of each cause category

cause.costs <- pipeline.df %>%
  select(Cause.Category,All.Costs) %>%
  group_by(Cause.Category) %>%
  summarise(Avg.Cost = mean(All.Costs / 1e6)) %>%
  arrange(desc(Avg.Cost))

cause.costs

# Taking a closer look at the subcategory for equipment failure
equip.sub <- pipeline.df %>%
  select(Cause.Category, Cause.Subcategory) %>%
  filter(Cause.Category == "MATERIAL/WELD/EQUIP FAILURE") %>%
  select(Cause.Subcategory)

# Taking a closer look at the subcategory for corrosion
corr.sub <- pipeline.df %>%
  select(Cause.Category, Cause.Subcategory) %>%
  filter(Cause.Category == "CORROSION") %>%
  select(Cause.Subcategory)





