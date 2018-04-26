library(randomForest)
library(e1071)
library(caret)

# Data Preparation
source("src/load.R")
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
spectTrain$pred_randomforest<-predict(model,spectTrain)

# Accuracy of the model
confusionMatrix(data = spectTrain$pred_randomforest,
                reference = spectTrain$V1)