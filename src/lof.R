# testing lofactor
library(DMwR2)
# for testing lof
library(Rlof)

# Load all the data..
source("src/load.R")

# SPECT: 0, 1
df<-spectTrain[-1]
cl <- factor(spectTrain[,1])
df.lof<-lof(df,c(1:4),cores=2)

# values > 1 are outliers (0)
df.lof[df.lof < 1.5]<-1
df.lof[df.lof > 1.5]<-0
df.lof[is.nan(df.lof)]<-1
print(df.lof)

quality <- mean(df.lof[,4] == spectTrain[,1])
print(quality)
# n=1: 0.5375
# n=2: 0.5125
# n=3: 0.525
# n=4: 0.625
# n=5: 0.5875
# n=6: 0.575
# n=7: 0.5625
# n=8: 0.575
# n=9: 0.5625
# n=10: 0.55
# rownie dobrze moglby losowac xd

# PHISHING: -1 or 1
trainSet<-pwebsites[-31]

m<-as.matrix(trainSet)
dims <- dim(m)
m <- as.numeric(m)
dim(m) <- dims 

result<-lof(m,c(1:5),cores=2)
result[is.nan(result)]<-0
result[result < 1.5]<-1
result[result > 1.5]<- -1
print(result)

quality <- mean(result[,4] == trainSet[,1])
print(quality)
# n=4: 0.5558571


# KDDCUP
trainSet<-kddcup[,-42]
m<-as.matrix(trainSet)
dims <- dim(m)
m <- as.numeric(m)
dim(m) <- dims 
result<-lof(trainSet,c(1:5),cores=2)

df.lof[df.lof < 1.5]<- FALSE
df.lof[df.lof > 1.5]<- TRUE

quality <- mean(result[,1] == trainSet[,1])
# n=5: 
# 
outlier.scores <- lofactor(df, k=10)
# outliers <- round(outlier.scores)
# outliers[is.na(outlier.scores)]<-1
# outliers[outliers > 2]<-0
# print(outliers)
