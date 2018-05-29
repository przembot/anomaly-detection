library(randomForest)
library(e1071)
library(caret)

library(pROC)

source("src/utils.R")

evaluate = function(trainData, testData, labelsColName, treeNum){
  # Prepare data
  trainData[,labelsColName] = as.factor(trainData[,labelsColName])
  testDataLabels = as.factor(testData[,labelsColName])
  testData[,labelsColName] <- NULL
  # Prepare formula
  varNames <- names(trainData)
  varNames <- varNames[!varNames %in% c(labelsColName)]
  varNames1 <- paste(varNames, collapse = "+")
  rf.form <- as.formula(paste(labelsColName, varNames1, sep = " ~ "))
  # Build the model
  cat("treeNum:",treeNum,"\n")
  model<-randomForest(rf.form,
                      data = trainData,
                      ntree=treeNum)
  # Predict using the model
  testData$pred_randomforest<-predict(model,testData)
  # Accuracy of the model
  quality <- evaluatePerformance(testDataLabels, testData$pred_randomforest)
  quality
}

generateRaport = function(trainData, testData, labelsColName) {
  treeNums = c(50,100,200,300, 400, 500, 900)
  qualities = matrix(nrow = length(treeNums),
                     ncol = 2)

  for (i in 1:length(treeNums)) {
      qualities[i,] = evaluate(trainData,
                               testData,
                               labelsColName,
                               treeNums[[i]])
  }
  graphROC(qualities)
}

rfMain = function() {
  generateRaport(spectTrain, spectTest, "V1")
  dev.copy(pdf,'./docs/images/spect_rf_2.pdf')
  dev.off()
  
  generateRaport(pwebsitesTrain, pwebsitesTest, "Result")
  dev.copy(pdf,'./docs/images/pweb_rf_2.pdf')
  dev.off()

  # to avoid error: Can not handle categorical predictors with more than 53 categories.
  # V3 : Factor w/ 66 levels
  # kddcup$V3 = as.numeric(as.character(kddcup$V3))
  # It is done in load.R
  generateRaport(kddcup, kddcupTest, "V42")
}
