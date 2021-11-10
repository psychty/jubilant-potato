
# Association rules - arules package R

library(easypackages)

libraries("readxl", "readr", "plyr", "dplyr", "ggplot2", "png", "tidyverse", "reshape2", "scales", 'zoo', 'stats',"rgdal", 'rgeos', "tmaptools", 'sp', 'sf', 'maptools', 'leaflet', 'leaflet.extras', 'spdplyr', 'geojsonio', 'rmapshaper', 'jsonlite', 'grid', 'aweek', 'xml2', 'rvest', 'officer', 'flextable', 'viridis', 'epitools', 'PostcodesioR', 'showtext', 'httr')

#install.packages('arules')
library(arules)

# https://michael.hahsler.net/research/arules_RUG_2015/demo/

crime_codes <- read_csv('crime_codes.csv') %>% 
  select(!X3)

# Tutorial using Stop Question and Frisk data 

if(!file.exists("SQF_Codebook.pdf")) {
  download.file("http://michael.hahsler.net/research/arules_RUG_2015/demo/SQF_Codebook.pdf", "SQF_Codebook.pdf")
}

if(!file.exists("SQF 2012.csv")) {
  download.file("http://michael.hahsler.net/research/arules_RUG_2015/demo/Stop-and-Frisk-2012.zip",
                "Stop-and-Frisk-2012.zip")
  unzip("Stop-and-Frisk-2012.zip")
}

df <- read_csv("SQF 2012.csv") %>% 
  mutate(datestop = as.Date(sprintf("%08d", datestop), format = '%m%d%Y')) %>% 
  mutate(timestop = as.integer(substr(sprintf("%04d", timestop), 1, 2))) %>% 
  mutate(perstop = as.numeric(perstop)) %>% 
  mutate(perobs = ifelse(perobs < 1 | perobs >120, NA, perobs)) %>% 
  mutate(age = ifelse(age < 10 | age >90, NA, age)) %>% 
  mutate(height = ifelse(height < 40 | height > 90, NA, height)) %>% 
  mutate(weight = ifelse(weight < 50 | weight > 400, NA, weight)) %>% 
  mutate(city = factor(city, labels = c("Manhattan", "Brooklyn", "Bronx","Queens", "Staten Island"))) %>% 
  mutate(race = factor(race, labels = c("Black", "Black Hispanic", "White Hispanic", "White", "Asian/Pacific Islander", "Am. Indian/ Native Alaskan"))) %>% 
  mutate(sex = factor(sex, labels = c('female', 'male'))) %>% 
  mutate(build = factor(build, labels = c('heavy', 'muscular', 'medium', 'thin'))) %>% 
  mutate(forceuse = factor(forceuse, labels = c("defense of other", "defense of self", "overcome resistence", "other", "suspected flight", "suspected weapon"))) %>% 
  mutate(inout = factor(inout+1L, labels = c('outside', 'inside'))) %>% 
  mutate(trhloc = factor(trhsloc+1L, labels = c('neither', 'houing authority', 'transit authority'))) %>% 
  select(!dob) %>% 
  mutate(detailcm = factor(detailcm, levels = crime_codes[,1], labels = crime_codes[,2])) %>% 
  mutate(pct = factor(pct),
         addrpct = factor(addrpct),
         sector = factor(sector),
         repcmd = factor(repcmd),
         revcmd = factor(revcmd)) %>% 
  mutate(typeofid = factor(typeofid, labels = c('photo id', 'verbal id', 'refused to provide id', 'unknown'))) %>% 
  select(!c(year, haircolr, eyecolor, ser_num, othfeatr, arstoffn, crimsusp, premname, addrnum, stname, stinter, crossst, beat, post, recstat, linecm))

# specify columns to turn into logical/boolean fields (true/false)
binary <- strsplit("frisked searched contrabn pistol riflshot asltweap knifcuti machgun othrweap arstmade sumissue sumoffen cs_objcs cs_descr cs_casng cs_lkout cs_cloth cs_drgtr cs_furtv cs_vcrim cs_bulge cs_other rf_vcrim rf_othsw rf_attir rf_vcact rf_rfcmp rf_verbl rf_knowl rf_furt rf_bulg sb_hdobj sb_outln sb_admis sb_other ac_proxm ac_evasv ac_assoc ac_cgdir ac_incid ac_time ac_stsnd ac_other ac_rept ac_inves pf_hands pf_wall pf_grnd pf_drwep pf_ptwep pf_baton pf_hcuff pf_pepsp pf_other othpers explnstp offunif offverb officrid offshld radio",
                   " ")[[1]]

for(b in binary) df[[b]] <- as.logical(df[[b]])

df <- df %>% 
  mutate(offverb = ifelse(offunif == TRUE, NA, offverb)) %>% 
  mutate(officrid = ifelse(offunif == TRUE, NA, officrid)) %>% 
  mutate(offshld = ifelse(offunif == TRUE, NA, offshld))

df %>% filter(is.na(city))

df %>% 
  group_by(city) %>% 
  summarise(Stops = n()) %>% 
  ggplot(aes(x = city,
             y = Stops)) +
  geom_bar(stat = 'identity')


d <- df[, c(
  grep("rf_", colnames(df), value = TRUE),
  grep("cs_", colnames(df), value = TRUE),
  grep("ac_", colnames(df), value = TRUE),
  grep("pf_", colnames(df), value = TRUE),
  "arstmade", "sumissue", "detailcm", "race",
  "pct",
  #"city", ### city and precinct are related
  "typeofid", "othpers"
)]

# make this binary
d$female <- df$sex == "female"

#d$detailcm[!(d$arstmade | d$sumissue)] <- NA
d$weapon <- df$pistol | df$riflshot | df$asltweap |
  df$knifcuti | df$machgun | df$othrweap

d$no_uniform <- !df$offunif

d$inside <- df$inout == "inside"
d$trhsloc <- df$trhsloc
d$trhsloc[df$trhsloc == "neither"] <- NA

#Continuous variables need to be discretized!
d$minor <- df$age <18
d$height <- discretize(df$height, method = "frequency", 3)

trans <- as(d, "transactions")
trans

summary(trans)
itemLabels(trans)
as(trans[1:2, 1:10], "matrix")

itemFrequencyPlot(trans, topN=50,  cex.names=.5)

d <- dissimilarity(sample(trans, 50000), method = "phi", which = "items")
d[is.na(d)] <- 1 # get rid of missing values

plot(hclust(d), cex=.5)
