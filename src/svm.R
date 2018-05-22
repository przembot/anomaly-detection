evaluatePerformance = function(testDataLabels, prediction, gamma, firstplot, color){
  cnfMx <- confusionMatrix(data = prediction,
                           reference = testDataLabels)
  # print(cnfMx)
  FPR = cnfMx$table[1,2]/(cnfMx$table[2,1]+cnfMx$table[2,2])
  quality <- mean(prediction == testDataLabels)
  # ROC
  rocObj <- roc(response = testDataLabels,
                predictor = as.numeric(prediction),
                percent=TRUE)
  xy = coords(rocObj, "best")
  plot(rocObj,
       add=!firstplot,
       grid=TRUE,
       xlim=if(rocObj$percent){c(100, 0)} else{c(1, 0)},
       col=color,
       # print.thres="best",
       print.auc = T,
       # print.auc.y = gamma*2,
       print.auc.pattern = paste(sprintf("gamma=%f, ",gamma),"AUC:%.1f%%"),
       main="ROC",
       type="p")
  ev = c(gamma, quality, xy[2:3], FPR)
  names(ev)<- c("gamma", "quality", "sensitivity", "specificity", "fall-out")
  ev <- as.data.frame(t(ev))
  return(ev)
}

evaluate = function(trainData, testData, labelsColName, gamma, firstplot, color){
  varNames <- names(trainData)
  varNames <- varNames[!varNames %in% c(labelsColName)]
  varNames1 <- paste(varNames, collapse = "+")
  rf.form <- as.formula(paste(labelsColName, varNames1, sep = " ~ "))
  testDataLabels = as.factor(testData[,labelsColName])
  testData[,labelsColName] <- NULL
  trainData[,labelsColName] <- as.numeric(as.character(trainData[,labelsColName]))
  # Build the model
  model <- svm(rf.form,
               data = trainData,
               type='one-classification',
               gamma=gamma,
               scale=FALSE, # do not scale each feature
               kernel="radial")
  print(summary(model))
  # Predict using the model
  predicion <- predict(model,testData)
  # Accuracy of the model
  print(table(predicion,testDataLabels))
  n_prediction <-as.factor(predicion)
  levels(testDataLabels) <- levels(n_prediction)
  print(levels(n_prediction))
  ev <- evaluatePerformance(testDataLabels, n_prediction, gamma, firstplot, color)
  return(ev)
}

evaluate = function(trainData, testData, labelsColName){
  varNames <- names(trainData)
  varNames <- varNames[!varNames %in% c(labelsColName)]
  varNames1 <- paste(varNames, collapse = "+")
  rf.form <- as.formula(paste(labelsColName, varNames1, sep = " ~ "))
  testDataLabels = as.factor(testData[,labelsColName])
  testData[,labelsColName] <- NULL
  trainData[,labelsColName] <- as.numeric(as.character(trainData[,labelsColName]))
  # Build the model
  model <- svm(rf.form,
               data = trainData,
               type='one-classification',
               scale=FALSE, # do not scale each feature
               kernel="radial")
  print(summary(model))
  # Predict using the model
  predicion <- predict(model,testData)
  # Accuracy of the model
  print(table(predicion,testDataLabels))
  n_prediction <-as.factor(predicion)
  levels(testDataLabels) <- levels(n_prediction)
  print(levels(n_prediction))
  ev <- evaluatePerformance(testDataLabels, n_prediction, model$gamma, T, 'green')
  return(ev)
}

generateRaport = function(trainData, testData, labelsColName) {
  gammas = c(0.125, 0.25, 0.5, 1, 2)
  lineColors = rainbow(length(gammas))
  qualities = matrix(nrow = length(gammas),ncol = 2)
  
  for (i in 1:length(gammas)) {
    qualities[i,] = evaluate(trainData, 
                             testData, 
                             labelsColName,
                             gammas[[i]],
                             i==1,
                             lineColors[[i]])
  }
  cat("best result:", qualities[qualities[,2]==max(qualities[,2]),])
}


evaluate(spectTrain, spectTest, "V1")
generateRaport(spectTrain, spectTest, "V1")
evaluate(pwebsitesTrain, pwebsitesTest, "Result")
evaluate(kddcup, kddcupTest, "V42")
generateRaport(trainData, trainDataLabels, testData, testDataLabels)

# --------------------------------------------------

## SPECT
spectTrain$V1 = as.factor(spectTrain$V1)
spect_model <- svm(V1 ~ ., 
                   data=spectTrain,
                   type='one-classification',
                   #nu=0.5,
                   scale=FALSE,
                   kernel="radial")
summary(spect_model)
spectTest$svm_pred <- predict(spect_model, spectTest)
confusionMatrix(data = as.factor(as.numeric(!spectTest$svm_pred)),
                                 reference = as.factor(spectTest$V1))
spect_model.quality <- mean(as.factor(as.numeric(!spectTest$svm_pred)) == as.factor(spectTest$V1))
# 0.8181818


## PHISHIHG Websites
pwebsites_model <- svm(Result ~ ., 
                   data=pwebsitesTrain,
                   type='one-classification',
                   nu=0.5,
                   scale=TRUE,
                   kernel="radial")
summary(pwebsites_model)
pwebsitesTest$svm_pred <- as.numeric(predict(pwebsites_model, pwebsitesTest))
pwebsitesTest$svm_pred[pwebsitesTest$svm_pred==0] <- -1
confusionMatrix(data = as.factor(as.numeric(pwebsitesTest$svm_pred)),
                reference = as.factor(pwebsitesTest$Result))
pwebsites_model.quality <- mean(as.factor(as.numeric(pwebsitesTest$svm_pred)) == as.factor(pwebsitesTest$Result))
# 0.5062855



## KDD CUP
trainSet <- kddcup
testSet <- kddcupTest
cl <- trainSet$V42
trainSet <- subset(trainSet, select=-V42)
table(cl)/nrow(trainSet)

kddcup_model <- svm(trainSet,
                    cl,
                    type='one-classification',
                    scale=FALSE,
                    kernel="radial")
summary(kddcup_model)

testSet$svm_pred <- predict(kddcup_model, testSet[,-42])
table(testSet$svm_pred, testSet$V42)
kddcup_model.quality <- mean(testSet$svm_pred == testSet$V42)

