# Dummy sid data

# Data dictionary ####
library(readr)
library(dplyr)

sid_data_dictionary <- read_csv("~/github/sid_data_dictionary.csv") # or wherever you have saved it
list_df <- split(sid_data_dictionary, sid_data_dictionary$table_name)

for(i in 1:length(list_df)){
  
  df_x =  as.data.frame(list_df[i]) %>%
    rename_at(1, ~'Table') %>% 
    rename_at(2, ~'Field') %>% 
    rename_at(3, ~'Note')
  
  assign(names(list_df[i]), df_x)
}

table_list <- read_csv('~/github/table_list.csv')

lsoa_lookup <- read_csv('https://opendata.arcgis.com/datasets/a46c859088a94898a7c462eeffa0f31a_0.csv') %>%
  left_join(read_csv('https://opendata.arcgis.com/datasets/180c271e84fc400d92ca6dcc7f6ff780_0.csv')[c('OA11CD', 'RGN11NM')], by = 'OA11CD') %>% 
  select(LSOA11CD, MSOA11CD, MSOA11NM, LAD20NM, RGN11NM) %>% 
  unique()

ssx_lsoas <- lsoa_lookup %>% 
  filter(LAD20NM %in% c('Brighton and Hove', 'Adur', 'Arun', 'Chichester', 'Crawley', 'Horsham', 'Mid Sussex', 'Worthing', 'Eastbourne', 'Hastings', 'Lewes', 'Rother', 'Wealden'))

# make a small proportion (around 1%) where age is not included (and so they cannot be counted in the NHS digital return)

partial_demographics <- data.frame(sid_id = 1:430) %>%  
  
  mutate(SEX = sample(x = c(1, 2), nrow(.), replace = TRUE, prob = c(0.38, 0.62))) %>% 
  mutate(SEX_CALC = ifelse(SEX == 1, 'Female', ifelse(SEX == 2, 'Male', NA))) %>% 
  mutate(Age = sample(x = c(18:83), nrow(.), replace = TRUE)) %>% 
  mutate(LSOA11 = sample(x = ssx_lsoas$LSOA11CD, nrow(.), replace = TRUE)) %>% 
  mutate(Acute_count = sample(x = c(0:4), nrow(.), replace = TRUE)) %>% 
  mutate(CommHosp_Count = sample(x = c(0:4), nrow(.), replace = TRUE)) %>% 
  mutate(GP_Count = sample(x = c(0:5), nrow(.), replace = TRUE)) %>% 
  mutate(SC_Count = sample(x = c(0:4), nrow(.), replace = TRUE)) %>% 
  mutate(MH_Count = sample(x = c(0:4), nrow(.), replace = TRUE)) 




# Load up into a virtual db ####  
