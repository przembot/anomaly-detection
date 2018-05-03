# Module which uses one class SVM classifier to detect anomalies
library(e1071)
library(caret)
# Load all the data..
source("src/load.R")

## SPECT
spectTrain$V1 = as.factor(spectTrain$V1)
spect_model <- svm(V1 ~ ., 
                   data=spectTrain,
                   type='one-classification',
                   nu=0.5,
                   scale=TRUE,
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



# 
# trainSet <- spectTrain
# # keep 'normal' values for training
# # trainSet <- subset(trainSet, V1==0)
# cl <- trainSet[,1]
# trainSet[,1] <- NULL
# testSet <- spectTest
# clTest <- testSet[,1]
# testSet[,1] <- NULL
# # TODO: verify one-classification type
# modelSpect <- svm(trainSet, cl, type='C-classification', kernel='linear')
# 
# pred <- predict(modelSpect, testSet)
# # table(pred, clTest)
# quality <- mean(pred == clTest)
