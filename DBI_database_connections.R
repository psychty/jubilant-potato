# Database connections in DBI

# thanks to Chris Mainey for his explainer on dbs in r


#install.packages(c('DBI', 'odbc', 'dbplyr', 'RSQLite', 'NHSRdatasets'))

library(easypackages)
libraries(c("readxl", "readr", "plyr", "dplyr", 'dbplyr', 'png', 'tidyverse', 'scales', 'zoo', 'stats', 'epitools', 'DBI', 'NHSRdatasets', 'RSQLite', 'odbc'))

# load A&E data from NHSRdatasets
data('ae_attendances')

# create a database in memory, add the ae_attendances data and remove the r object ae_attendances
con <- dbConnect(RSQLite::SQLite(), ':memory:')
dbWriteTable(con, 'ae_attendances', ae_attendances, overwrite = TRUE)
rm(ae_attendances)

# exploring the database ####
tables_in_db <- dbListTables(con)

# what fields are in the ae_attendances table
dbListFields(con, 'ae_attendances')

# what types are in the table field type
query = "SELECT distinct type, count(*) 
         FROM ae_attendances 
         GROUP BY type"

# You need to send the query and fetch the results
dbSendQuery(con, query) %>% 
  dbFetch()


# what types are in the table field type
query = "SELECT distinct type, count(*) 
         FROM ae_attendances
         WHERE org_code = 'RRK'
         GROUP BY type"

dbSendQuery(con, query) %>% 
  dbFetch()


# Using dplyr ####
# You can use database tables as R tibbles (to use in dplyr pipes), even though the data itself is not in R.
ae <- tbl(con, 'ae_attendances')

ae %>% 
  glimpse()


org_code_x <- ae %>% 
  select(org_code, attendances) %>% 
  filter(attendances < 500) %>% 
  collect() %>% 
  select(org_code) %>% 
  unique() %>% 
  as.character()

ae %>% 
  select(org_code, attendances) %>% 
  view()

# use dplyr verbs to create the same query
ae %>% 
  filter(org_code %in% org_code_x) %>% 
  group_by(type) %>% 
  show_query()


# return the SQL query that your dplyr verbs are running
ae %>% 
  filter(org_code == 'RRK') %>% 
  group_by(type) %>% 
  summarise(Count = n()) %>% 
  show_query()

# bring the data into an R object
df <- ae %>% 
  filter(org_code == 'RRK') %>% 
  group_by(type) %>% 
  summarise(Count = n()) %>% 
  collect()

# It is quicker to do stuff server side
