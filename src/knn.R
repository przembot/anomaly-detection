# Module which uses k-nn classifier to detect anomalies
library(class)

# Load all the data..
source("src/load.R")

# Currently, training set is the model,
# but this set can be reduced by 'condense'

# SPECT

# Move classification result to factor

cl <- factor(spectTrain[,1])
trainSet <- spectTrain
testSet <- spectTest

# remove column with labels
trainSet[,1] <- NULL
testSet[,1] <- NULL

# classify
result <- knn(trainSet, testSet, cl, k = 1, prob=FALSE)

# n = 1: 0.625
# n = 3: 0.652
# n = 5: 0.598
quality <- mean(result == spectTest[,1])


# Phishing Websites

# TODO: split training/test set?

cl <- factor(pwebsites[,31])
trainSet <- pwebsites

trainSet[,31] <- NULL

result <- knn(trainSet, trainSet, cl, k = 5, prob=FALSE)

# n = 1: 0.989
# n = 3: 0.965
# n = 5: 0.956
quality <- mean(result == pwebsites[,31])


# KDD CUP

cl <- factor(kddcup[,42])
trainSet <- kddcup
trainSet[,42] <- NULL
testSet <- kddcupTest
testSet[,42] <- NULL

result <- knn(trainSet, testSet, cl, k = 1, prob=FALSE)
quality <- mean(result == kddcupTest[,42])