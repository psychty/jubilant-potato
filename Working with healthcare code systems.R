
# devtools::install_github("jackwasey/icd")

library(easypackages)

libraries("readxl", "readr", "plyr", "dplyr", "ggplot2", "png", "tidyverse", "reshape2", "scales", 'zoo', 'stats',"rgdal", 'rgeos', "tmaptools", 'sp', 'sf', 'maptools', 'leaflet', 'leaflet.extras', 'spdplyr', 'geojsonio', 'rmapshaper', 'jsonlite', 'grid', 'aweek', 'xml2', 'rvest', 'officer', 'flextable', 'viridis', 'epitools', 'PostcodesioR', 'showtext', 'httr', 'icd')


snomed_decription_Full_en_INT_20210131 <- read_delim("C:/Users/richt/Downloads/uk_sct2cl_32.6.0_20211027000001Z/SnomedCT_InternationalRF2_PRODUCTION_20210131T120000Z/Full/Terminology/sct2_Description_Full-en_INT_20210131.txt", 
                                                    "\t", escape_double = FALSE, col_types = cols(moduleId = col_character(), 
                                                                                                  typeId = col_character(), caseSignificanceId = col_character()), 
                                                    trim_ws = TRUE)
View(sct2_Description_Full_en_INT_20210131)


install.packages('coder')
library(coder)