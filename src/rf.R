library(randomForest)
library(e1071)
library(caret)

library(pROC)

# Data Preparation
source("src/load.R")

evaluatePerformance = function(testDataLabels, prediction, firstplot, color){
  print(confusionMatrix(data = prediction,
                        reference = testDataLabels))
  quality <- mean(prediction == testDataLabels)
  cat("quality:",quality,"\n")
  # ROC
  rocObj <- roc(response = testDataLabels,
                predictor = as.numeric(prediction),
                percent=TRUE)
  print(coords(rocObj, "best"))
  plot(rocObj,
       add=!firstplot,
       grid=TRUE,
       col=color,
       print.thres="best",
       main="ROC")
  return(quality)
}

evaluate = function(trainData, testData, labelsColName, treeNum, firstplot, color){
  # Prepare formula
  varNames <- names(trainData)
  varNames <- varNames[!varNames %in% c(labelsColName)]
  varNames1 <- paste(varNames, collapse = "+")
  rf.form <- as.formula(paste(labelsColName, varNames1, sep = " ~ "))
  # Build the model
  cat("treeNum:",treeNum,"\n")
  testDataLabels = as.factor(testData[,labelsColName])
  testData[,labelsColName] <- NULL
  model<-randomForest(rf.form,
                      data = trainData,
                      ntree=treeNum,
                      importance=T)
  # Predict using the model
  testData$pred_randomforest<-predict(model,testData)
  # Accuracy of the model
  quality <- evaluatePerformance(testDataLabels, testData$pred_randomforest, firstplot, color)
  return(c(treeNum, quality))
}

generateRaport = function(trainData, testData, labelsColName) {
  treeNums = c(1,2,5,10,20,50,100,200)
  lineColors = rainbow(length(treeNums))
  qualities = matrix(nrow = length(treeNums),
                     ncol = 2)
  
  for (i in 1:length(treeNums)) {
      qualities[i,] = evaluate(trainData,
                               testData, 
                               labelsColName, 
                               treeNums[[i]], 
                               i==1,
                               lineColors[[i]])
  }
  cat("best result:", qualities[qualities[,2]==max(qualities[,2]),])
}

main = function() {
  generateRaport(spectTrain, spectTest, "V1")
  # best result: 3 0.7860963
  generateRaport(pwebsitesTrain, pwebsitesTest, "Result")
  # best result: 20 0.9597195
  generateRaport(kddcup, kddcupTest, "V42")
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