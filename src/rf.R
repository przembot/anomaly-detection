source("src/utils.R")

evaluatePerformance = function(testDataLabels, prediction){
  quality <- mean(prediction == testDataLabels)
  cat("quality:",quality,"\n")

  perf <- confusionMatrix(data = prediction,
                          reference = testDataLabels,
                          positive = "1")

  print(perf)
  sens = perf$table[2,2]*100/(perf$table[1,2]+perf$table[2,2])
  spec = perf$table[1,1]*100/(perf$table[1,1]+perf$table[2,1])

  c(sens, spec)
}

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
  treeNums = c(50,100,200,300, 400, 500, 600, 700, 800, 900)
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

main = function() {
  kddcup$V3 = as.numeric(as.character(kddcup$V3))

  # generateRaport(spectTrain, spectTest, "V1")
  generateRaport(pwebsitesTrain, pwebsitesTest, "Result")

  # to avoid error: Can not handle categorical predictors with more than 53 categories.
  # V3 : Factor w/ 66 levels
  # kddcup$V3 = as.numeric(as.character(kddcup$V3))
  # Error in predict.randomForest(): New factor levels not present in the training data
  # generateRaport(kddcup, kddcupTest, "V42")
}
