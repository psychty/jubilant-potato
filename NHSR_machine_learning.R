library(easypackages)
libraries(c("readxl", "readr", "plyr", "dplyr", 'dbplyr', 'png', 'tidyverse', 'scales', 'zoo', 'stats', 'epitools', 'DBI', 'NHSRdatasets', 'RSQLite'))

#install.packages(c('xts', 'quantmod', 'ROCR'))
# packageurl <- "https://cran.r-project.org/src/contrib/Archive/DMwR/DMwR_0.4.1.tar.gz"
# install.packages(packageurl, repos=NULL, type="source")

library(DMwR)

df <- stranded_data

table(df$stranded.label)

# class imbalance, if you have a dataset which is 60% one outcome (outcome A) and 40% another outcome (outcome B), then a model would probably become better at predicting outcome A.  

# You can use synthetic minority oversampling to rebalance an unbalanced classification.This iS appropriate for modest imbalance, and even up to 75/25 or 80/20, but when you have an outcome that is present in less than 10% of your sample, then SMOTE and ML may not be appropriate

balanced_df <- SMOTE(stranded.label~., df, perc.over = 200, perc.under = 120) %>% 
  as.data.frame() %>% 
  drop_na()

