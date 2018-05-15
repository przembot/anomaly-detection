# Module which uses one class SVM classifier to detect anomalies
library(e1071)
library(caret)
library(pROC)
# Load all the data..
source("src/load.R")

# evaluate = function(trainData, trainDataLabels, testData, testDataLabels, nu, firstplot, color){
#   # Build the model
#   model <- svm(x = trainData,
#                y = trainDataLabels,
#                type='one-classification',
#                nu=nu,
#                scale=FALSE,
#                kernel="radial")
#   # Predict using the model
#   predicion <- predict(model,testData)
#   # Accuracy of the model
#   print(levels(as.factor(testDataLabels)))
#   print(class(testDataLabels))
#   print(levels(as.factor(predicion)))
#   print(class(predicion))
#   quality <- evaluatePerformance(as.factor(testDataLabels), as.factor(predicion), firstplot, color)
#   return(quality)
# }

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
       print.auc.y = gamma*2,
       print.auc.pattern = paste(sprintf("gamma=%f, ",gamma),"AUC:%.1f%%"),
       main="ROC",
       type="p")
  # Add a legend
  # legend("bottomright", legend=sprintf("gamma:%d, auc:%f",gamma,auc(rocObj),"\n"),fill=color, col=color, cex = 0.8)
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

## SPECT
trainData = spectTrain
testData = spectTest
labelsColName = "V1"
trainDataLabels = !trainData[,labelsColName]
trainData[,labelsColName] <- NULL
testDataLabels = !testData[,labelsColName]
testData[,labelsColName] <- NULL

svm_tune <- tune.svm(trainData,
                     trainDataLabels,
                     type="one-classification",
                     kernel="radial",
                     gamma = c(0.001, 0.01, 0.1, 0.5))


evaluate(spectTrain, spectTest, "V1", 0.001, TRUE, 'green')
generateRaport(spectTrain, spectTest, "V1")
evaluate(pwebsitesTrain, pwebsitesTest, "Result", 0.001, T, 'green')
evaluate(kddcup, kddcupTest, "V42", 0.4, T, 'green')
generateRaport(trainData, trainDataLabels, testData, testDataLabels)


## PHISHIHG Websites
trainData = pwebsitesTrain
testData = pwebsitesTest
labelsColName = "Result"
trainDataLabels = trainData[,labelsColName]
trainData[,labelsColName] <- NULL
testDataLabels = testData[,labelsColName]
levels(testDataLabels) <- c(T,F)
testData[,labelsColName] <- NULL

svm_tune <- tune(svm, train.x=trainData, train.y=trainDataLabels, 
                 kernel="radial", ranges=list(cost=10^(-1:2), gamma=c(0.001, 0.01, 0.1,.5,1,2)))

print(svm_tune)

evaluate(trainData, as.numeric(trainDataLabels), testData, as.logical(testDataLabels), 0.4,TRUE, 'green')






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

tune.svm(trainSet,
         cl,
         type="one-classification",
         kernel="radial",
         cost=seq(.5,2.5,.5),
         cachesize=100,
         cross=10,
         gamma=1/8)

#- sampling method: 10-fold cross validation 
# - best parameters:
#   gamma cost
# 0.125  0.5
# - best performance: 0.460625 

kddcup_model <- svm(trainSet,
                    cl,
                    type='one-classification',
                    scale=FALSE,
                    kernel="radial")
summary(kddcup_model)

testSet$svm_pred <- predict(kddcup_model, testSet[,-42])
table(testSet$svm_pred, testSet$V42)
kddcup_model.quality <- mean(testSet$svm_pred == testSet$V42)

