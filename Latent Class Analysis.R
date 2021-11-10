
library(easypackages)

libraries(c("readxl", "readr", "plyr", "dplyr", "ggplot2", "png", "tidyverse", "reshape2", "scales", "viridis", "rgdal", "officer", "flextable", "tmaptools", "lemon", "fingertipsR", "jsonlite", 'datasets'))


# K means ####

# K Means Clustering is unsupervised. This means that there is no outcome to be predicted,  we are simply finding patterns in the data (it is data-driven). We do need to specify the number of clusters we want to find and the algorithm randomly assigns each observation to a cluster, finds the centroid of each cluster, then reassigns datapoints to the cluster whose centroid is closest until within cluster variation cannoted by reduced further.

# Cluster variation is calculated as the sum of the euclidean distance between data points and their respective cluster centroids.

iris %>% view()

iris %>% ggplot(aes(x = Petal.Length,
                    y = Petal.Width,
                    color = Species)) +
  geom_point()

# Initial assignments are random

set.seed(20)

irisCluster <- kmeans(x = iris[, 3:4], # x needs to be a numeric matrix of data (all numeric dataframe)
                      centers = 3, # number of clusters 
                      nstart = 20) # number of random starting assignments from which to choose the lowest cluster variation.


# How well did the k means clustering classify the data into the three species?
table(irisCluster$cluster, iris$Species)


# Hierarchical clustering ####

# Hierarchical clustering builds a hierarchy from the bottom up, without requiring us to specify the number of clusters apriori 

# Each data point is given its own cluster, and the two closest clusters are combined and this is repeated until all data points are in a single cluster.

# the closeness of clusters can be determined by a few methods - 

# 1) Complete linkage clustering (maximum possible distance between points belonging to two different clusters)
# 2) Single linkage clustering (minimum possible distance)
# 3) Mean linkage clustering (all possible pairwise distances for points belonging to two different clusters then calculate the average)
# 4) Centroid linkage clustering

distance_matrix <- dist(iris[, 3:4])

clusters <- hclust(distance_matrix)

plot(clusters)