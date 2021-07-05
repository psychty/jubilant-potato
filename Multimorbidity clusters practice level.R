

# https://rpubs.com/jflowers/458789

# practice level multimorbidity clustering -
# unsupervised machine learning

# packages ###

library(easypackages)

# NbClust - determines optimum number of clusters
# factoextra - extracts and vidsualises results of multivariate analyses and simplifies cluster analysis
# skimr - summary functions
# naniar - imputation 

libraries('fingertipsR',  'tidyverse', 'NbClust', 'factoextra', 'FactoMineR', 'skimr', 'naniar', 'cluster')

# For this analysis we are interested in extracting prevalence estimates, deprivation scores and demographic variables (prevalence estimates are not age-adjusted)

# The str_detect() is looking for OR with the | as well as looking for [Dd] capital D or normal d depri when looking for deprivation 

# fingertipsR does not work on the ESCC version of R. We might need to request R is updated. We can get around it using the read_csv workaround, but it is slow when trying to get data for all practices in England as were doing for this exercise.


gp_indicators <- indicator_areatypes() %>%
  filter(AreaTypeID == 7) %>% 
  left_join(indicators(), by = 'IndicatorID') %>%
  select(IndicatorID, IndicatorName) %>%  
  filter(str_detect(IndicatorName, "prevalence|[Dd]epri|long-term|nursing|aged")) %>% 
  unique()

ids <- gp_indicators %>%
  pull(IndicatorID) %>%
  unique()

#data <- fingertips_data(IndicatorID = ids, AreaTypeID = 7)

#data %>% write_rds("gp_cluster_data.rds", compress = "gz")

url <- "https://github.com/psychty/jubilant-potato/raw/main/gp_cluster_phedata.rds"
gp_cluster_data <- readRDS(url(url, method="libcurl"))

gp_cluster_data <- readRDS('./GitHub/jubilant-potato/gp_cluster_phedata.rds') 

# Some of the GP data indicators are retired, and these can be extracted from the dataset, again using str_detect()
retired_data <- gp_cluster_data %>%
  filter(str_detect(IndicatorName, "retired"))

# Use the same command but ! (exclude) retired indicators and then also only keep GP data rather than the national and regional benchmarks
gp_cluster_data <- gp_cluster_data %>% 
  filter(!str_detect(IndicatorName, 'retired')) %>% 
  filter(AreaType == "GP") 

# gp_cluster_data %>% 
#   group_by(AreaType) %>% 
#   summarise(n())

# Use group_by() to capture the latest available time period for each indicator
latest_gp_cluster_data <- gp_cluster_data %>%
  group_by(IndicatorID, Age, Sex) %>%
  filter(TimeperiodSortable == max(TimeperiodSortable)) %>% 
  ungroup() %>% 
  filter(Age != 'Not applicable') %>% 
  filter(!(IndicatorID == '93211' & Age == '<40 yrs')) %>% 
  filter(!(IndicatorID == '93204' & Age == 'All ages')) %>% 
  filter(!(IndicatorID == '93205' & Age == 'All ages')) %>% 
  filter(!(IndicatorID == '93206' & Age == 'All ages')) %>% # There are some weird entries for type 1 diabetes
  select(IndicatorID, IndicatorName, AreaName, AreaCode, Timeperiod, Value, Age) %>% 
  unique()
  
# latest_gp_cluster_data %>% 
#     filter(AreaCode == 'P87657') %>% 
#     view()

# This turns the alphabetised order of a variable into a factor and reverses the order. ggplot always plots from inside outwards. so you'd normally expect a to be closer to 0 than z.
#?fct_rev()

## visualise the latest available time periods for each dataset
ggplot(latest_gp_cluster_data,
       aes(x = fct_rev(IndicatorName),
           y = Timeperiod)) +
  geom_tile(fill = "red") +
  coord_flip() +
  labs(title = "Latest period for each indicator", 
       y = "Year", 
       x = "") +
  theme(axis.text = element_text(size = rel(.7)))

# How much is missing
summary(latest_gp_cluster_data) # This shows 153 datapoints missing, and this is 

paste0(round(nrow(subset(latest_gp_cluster_data, is.na(Value))) / nrow(latest_gp_cluster_data) * 100, 3), '% of values are missing in this dataset.')

# If there were missing values across different variables then using something like vis_miss would be helpful, but with less than .05% of values missing it does not show much.
# vis_miss(latest_gp_cluster_data,
         # warn_large_data = FALSE)

# Impute missing data values using the median
latest_data_imputed <- latest_gp_cluster_data %>%
  group_by(IndicatorID, Timeperiod) %>%
  mutate(Value = ifelse(is.na(Value), median(Value, na.rm = TRUE), Value)) 

scaled <- latest_data_imputed %>%
  ungroup() %>%
  mutate(index = paste(IndicatorName, Age,  Timeperiod)) %>%
  select(index, Value, AreaName, AreaCode) %>%
  spread(index, Value) %>%
  mutate_if(is.numeric, function(x) ifelse(is.na(x), median(x, na.rm = TRUE), x)) %>%
  mutate_if(is.numeric, scale)

scaled[, -c(1:2)] %>%
  cor() %>%
  corrplot::corrplot(tl.cex = .5, tl.col = "black", order = "hclust", method = "ellipse", addrect = 6)

# library(devtools)
# install_github("jokergoo/ComplexHeatmap")

library(ComplexHeatmap)
ComplexHeatmap::Heatmap(scaled)

