library(tidyverse)
library(magrittr)
library(jsonlite)

footprint_data <- read.csv("/home/cam/Documents/ECS 163/Project 1/src/data/NFA 2018.csv",header = TRUE)
footprint_data %<>%  select(-UN_region,-UN_subregion) %>% drop_na %>% 
  rename(Forest_Land = forest_land)

write.csv(footprint_data,"/home/cam/Documents/ECS 163/Project 1/src/data/attr_data.csv")
footprint_data <- toJSON(unname(split(footprint_data,1:nrow(footprint_data))))

write_json(footprint_data,"/home/cam/Documents/ECS 163/Project 1/src/data/attr_data.json")
