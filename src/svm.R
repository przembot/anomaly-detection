# Module which uses one class SVM classifier to detect anomalies
library(e1071)
library(caret)
library(pROC)
# Load all the data..
#source("src/load.R")

source("src/utils.R")

evaluatePerformance = function(testDataLabels, prediction) {
  quality <- mean(prediction == testDataLabels)
  cat("quality:",quality,"\n")
  
  dataIn <- as.factor(prediction)
  levels(dataIn) <- c(0, 1)
  refIn <- as.factor(testDataLabels)
  levels(refIn) <- c(0, 1)
  
  perf <- confusionMatrix(data = dataIn,
                          reference = refIn,
                          positive = "1")
  
  print(perf)
  sens = perf$table[2,2]*100/(perf$table[1,2]+perf$table[2,2])
  spec = perf$table[1,1]*100/(perf$table[1,1]+perf$table[2,1])
  
  c(sens, spec)
  
}

evaluate = function(trainData, testData, labelsColName, gamma) {
  varNames <- names(trainData)
  varNames <- varNames[!varNames %in% c(labelsColName)]
  varNames1 <- paste(varNames, collapse = "+")
  rf.form <- as.formula(paste(labelsColName, varNames1, sep = " ~ "))
  testDataLabels = as.factor(testData[,labelsColName])
  testData[,labelsColName] <- NULL
  trainData[,labelsColName] <- as.factor(trainData[,labelsColName])
  # Build the model
  model <- svm(rf.form,
               data = trainData,
               type='one-classification',
               gamma=gamma,
               scale=FALSE, # do not scale each feature
               kernel="radial")
  print(summary(model))
  # Predict using the model
  prediction <- predict(model,testData)
  
  ev <- evaluatePerformance(testDataLabels, prediction)
  ev
}

generateRaport = function(trainData, testData, labelsColName) {
  gammas = c(0.1, 0.125, 0.2, 0.25, 0.5, 0.8, 1, 2)
  qualities = matrix(nrow = length(gammas),ncol = 2)
  
  for (i in 1:length(gammas)) {
    qualities[i,] = evaluate(trainData, 
                             testData, 
                             labelsColName,
                             gammas[[i]])
  }
  graphROC(qualities)
}

main = function() {
  generateRaport(spectTrain, spectTest, "V1")
  generateRaport(pwebsitesTrain, pwebsitesTest, "Result")
  #generateRaport(kddcup, kddcupTest, "V42")
}