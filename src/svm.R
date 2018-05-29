# Module which uses one class SVM classifier to detect anomalies
library(e1071)
library(caret)
library(pROC)

source("src/utils.R")

evaluate = function(trainData, testData, labelsColName, gamma) {
  varNames <- names(trainData)
  varNames <- varNames[!varNames %in% c(labelsColName)]
  varNames1 <- paste(varNames, collapse = "+")
  rf.form <- as.formula(paste(labelsColName, varNames1, sep = " ~ "))
  testDataLabels = testData[,labelsColName]
  testData[,labelsColName] <- NULL
  trainData[,labelsColName] <- trainData[,labelsColName]
  # Build the model
  model <- svm(rf.form,
               data = trainData,
               type='one-classification',
               gamma=gamma,
               # degree = 3,
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

svmMain = function() {
  generateRaport(spectTrain, spectTest, "V1")
  dev.copy(pdf,'./docs/images/spect_svm_linear.pdf')
  dev.off()
  
  generateRaport(pwebsitesTrain, pwebsitesTest, "Result")
  dev.copy(pdf,'./docs/images/pweb_svm_polynomial.pdf')
  dev.off()
}