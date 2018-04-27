# Module which uses one class SVM classifier to detect anomalies
library(e1071)
library(caret)
# Load all the data..
source("src/load.R")

# SPECT
spectTrain$V1 = as.factor(spectTrain$V1)
model <- svm(V1 ~ ., 
             data=spectTrain,
             type='one-classification',
             nu=0.5,
             scale=TRUE,
             kernel="radial")
summary(model)
spectTest$svm_pred <- predict(model, spectTest)
confusionMatrix(data = as.factor(as.numeric(!spectTest$svm_pred)),
                reference = as.factor(spectTest$V1))
quality <- mean(as.factor(as.numeric(!spectTest$svm_pred)) == as.factor(spectTest$V1))
# 0.8181818


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
