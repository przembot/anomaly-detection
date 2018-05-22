# Load all the data..
source("src/load.R")

# Load modules
# Module which uses one class SVM classifier to detect anomalies
library(e1071)
library(caret)
# Module which uses k-nn classifier to detect anomalies
library(class)
# Random forest
library(randomForest)
# iForest algorithm implementation
library(data.tree)
# Ploting ROC
library(pROC)

# if(exists("main", mode = "function"))
#   source("src/knn.R")
#   main()
# 
# if(exists("main", mode = "function"))
#   source("src/svm.R")
#   main()
# if(exists("main", mode = "function"))
#   source("src/rf.R")
#   main()
if(exists("main", mode = "function"))
  source("src/iforest.R")
  main()