library(randomForest)
library(e1071)
library(caret)

# Data Preparation
source("src/load.R")

## SPECT
str(spectTrain)

# Make class variable as a factor (categorical)
spectTrain$V1 = as.factor(spectTrain$V1)

# Prepare formula
varNames <- names(spectTrain)
varNames <- varNames[!varNames %in% c("V1")]
varNames1 <- paste(varNames, collapse = "+")
rf.form <- as.formula(paste("V1", varNames1, sep = " ~ "))

# Build the model
model<-randomForest(rf.form,
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