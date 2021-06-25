

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

gp_indicators <- indicator_areatypes() %>%
  filter(AreaTypeID == 7) %>% 
  left_join(indicators(), by = 'IndicatorID') %>%
  select(IndicatorID, IndicatorName) %>%  
  filter(str_detect(IndicatorName, "prevalence|[Dd]epri|long-term|nursing|aged")) %>% 
  unique()

ids <- gp_indicators %>%
  pull(IndicatorID) %>%
  unique()

data <- fingertips_data(IndicatorID = ids, AreaTypeID = 7)

data %>% write_rds("gp_cluster_data.rds", compress = "gz")
