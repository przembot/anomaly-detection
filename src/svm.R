# Module which uses one class SVM classifier to detect anomalies
library(e1071)

# Load all the data..
source("src/load.R")

# SPECT

trainSet <- spectTrain
# keep 'normal' values for training
# trainSet <- subset(trainSet, V1==0)
cl <- trainSet[,1]
trainSet[,1] <- NULL
testSet <- spectTest
clTest <- testSet[,1]
testSet[,1] <- NULL
# TODO: verify one-classification type
modelSpect <- svm(trainSet, cl, type='C-classification', kernel='linear')

pred <- predict(modelSpect, testSet)
# table(pred, clTest)
quality <- mean(pred == clTest)
