library(easypackages)

libraries("readxl", "readr", "plyr", "dplyr", "ggplot2", "png", "tidyverse", "reshape2", "scales", 'zoo', 'stats',"rgdal", 'rgeos', "tmaptools", 'sp', 'sf', 'maptools', 'leaflet', 'leaflet.extras', 'spdplyr', 'geojsonio', 'rmapshaper', 'jsonlite', 'grid', 'aweek', 'xml2', 'rvest', 'officer', 'flextable', 'viridis', 'epitools', 'PostcodesioR')

github_repo_dir <- '~/GitHub/jubilant-potato'
output_directory_x <- paste0(github_repo_dir, '/')

eligible_ages <- c('40-44 years','45-49 years', '50-54 years', '55-59 years', '60-64 years', '65-69 years', '70-74 years', '75-79 years', '80-84 years', '85-89 years', '90 and over')

Status <- c('Received first dose only', 'Received two doses', 'Yet to receive single dose')
Age_group <- c('Not yet eligible due to age alone', eligible_ages)

dummy_data <- data.frame(Age_group = rep(Age_group, length(Status)), Status = rep(Status, length(Age_group)), Individuals = sample(1:400, length(Status)*length(Age_group), replace=TRUE))

dummy_data %>% 
  toJSON() %>% 
  write_lines(paste0(output_directory_x, 'black_age_status.json'))
