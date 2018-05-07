library(randomForest)
library(e1071)
library(caret)

library(pROC)

# Data Preparation
source("src/load.R")

evaluate = function(trainData, testData, labelsColName, treeNum){
  # Prepare formula
  varNames <- names(trainData)
  varNames <- varNames[!varNames %in% c(labelsColName)]
  varNames1 <- paste(varNames, collapse = "+")
  rf.form <- as.formula(paste(labelsColName, varNames1, sep = " ~ "))
  # Build the model
  model<-randomForest(rf.form,
                      data = trainData,
                      ntree=treeNum,
                      importance=T)
  # Predict using the model
  testData$pred_randomforest<-predict(model,testData)
  # Accuracy of the model
  testDataLabels = as.factor(testData[,labelsColName])
  print(confusionMatrix(data = testData$pred_randomforest,
                 reference = testDataLabels))
  quality <- mean(testData$pred_randomforest == testDataLabels)
  print(quality)
  # ROC
  rocObj <- roc(response = testDataLabels,
                predictor = as.numeric(testData$pred_randomforest),
                percent=TRUE)
  print(coords(rocObj, "best"))
  plot(rocObj,
       grid=TRUE,
       print.thres="best",
       main="ROC")
}


main = function() {
  # testing evaluate
  evaluate(spectTrain, spectTest, "V1", 500)
  evaluate(pwebsitesTrain, pwebsitesTest, "Result", 500)
}


## SPECT
str(spectTrain)

# Make class variable as a factor (categorical)
spectTrain$V1 = as.factor(spectTrain$V1)

# Build the model
model<-randomForest(V1 ~.,
                    data=spectTrain,
                    ntree=500,
                    importance=T)

# Summarize the model
plot(model)
summary(model)

# Predict using the model
spectTest$pred_randomforest<-predict(model,spectTest)

# Accuracy of the model
confusionMatrix(data = spectTest$pred_randomforest,
                reference = as.factor(spectTest$V1))
quality <- mean(spectTest$pred_randomforest == spectTest$V1)
# train: 0.9375
# test: 0.7754011
rocObj <- roc(response = spectTest$V1,
              predictor = as.numeric(as.character(spectTest$pred_randomforest)),
              percent=TRUE)
print(coords(rocObj, "best"))
plot(rocObj,
     grid=TRUE,
     print.thres="best",
     main="ROC")


## PHISHING
pwebsites$Result = as.factor(pwebsites$Result)
trainSet <- pwebsitesTrain
testSet <- pwebsitesTest

# Build the model
model<-randomForest(Result ~ .,
                    data=trainSet,
                    ntree=500,
                    importance=T)
plot(model)
summary(model)

# Predict using the model
testSet$pred_randomforest<-predict(model,testSet)

# Accuracy of the model
confusionMatrix(data = testSet$pred_randomforest,
                reference = as.factor(testSet$Result))
quality <- mean(testSet$pred_randomforest == testSet$Result)
# train: 0.9803709
# test: 0.9604655


## KDD CUP
trainSet <- kddcup
testSet <- kddcupTest
trainSet$V42 = as.factor(trainSet$V42)
testSet$V42 = as.factor(testSet$V42)

# to avoid error: Can not handle categorical predictors with more than 53 categories.
# V3 : Factor w/ 66 levels
trainSet$V3 = as.numeric(as.character(trainSet$V3))

# Build the model
model<-randomForest(V42 ~ .,
                    data=trainSet,
                    ntree=500,
                    importance=T)
plot(model)
summary(model)

# Predict using the model
testSet$pred_randomforest<-predict(model,testSet)

# Accuracy of the model
confusionMatrix(data = testSet$pred_randomforest,
                reference = testSet$V42)
quality <- mean(testSet$pred_randomforest == testSet$V42)
# train: 
# test: 