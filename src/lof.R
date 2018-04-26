# testing lofactor
library(DMwR2)
# for testing lof
library(Rlof)

# Load all the data..
source("src/load.R")

cl <- factor(spectTrain[,1])

df<-spectTrain[-1]
df.lof<-lof(df,c(5:10),cores=2)
df.lof[df.lof < 1.5]<-1
df.lof[df.lof > 1.5]<-0
quality <- mean(df.lof[,1] == spectTest[,1])
# n=5: 
# 
outlier.scores <- lofactor(df, k=10)
# outliers <- round(outlier.scores)
# outliers[is.na(outlier.scores)]<-1
# outliers[outliers > 2]<-0
# print(outliers)
