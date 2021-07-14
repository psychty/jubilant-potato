
# Machine learning - Breast Cancer detection with a Support Vector Machine (SVM) and k-nearest neighbours clustering model to compare results

library(readr)
breast_cancer_wisconsin <- read_csv("https://archive.ics.uci.edu/ml/machine-learning-databases/breast-cancer-wisconsin/breast-cancer-wisconsin.data", col_names = c('id', 'clump_thickness', 'uniform_cell_size', 'uniform_cell_shape', 'marginal_adehsion', 'single_epithelial_size', 'bare_nuclei', 'bland_chromatin', 'normal_nucleioli', 'mitoses', 'class'))
