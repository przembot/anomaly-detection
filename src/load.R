# Load all available data into R
library(farff)

# Utils

# Given data frame and column number,
# give each element in column unique numeric value
factorize <- function(data, columnNumber) {
  buffer <- factor(data[,columnNumber])
  levels(buffer) <- 1:length(levels(buffer))
  eval.parent(substitute(data[,columnNumber] <- buffer))
}



# Phishing websites
# Last column has labels
pwebsites = readARFF("data/PW.arff")
# split the data sample into train and test samples
sample.ind <- sample(2, 
                     nrow(pwebsites),
                     replace = TRUE,
                     prob = c(0.4,0.6))
pwebsitesTrain <- pwebsites[sample.ind==1,]
pwebsitesTest <- pwebsites[sample.ind==2,]
table(pwebsitesTrain$Result)/nrow(pwebsitesTrain)
table(pwebsitesTest$Result)/nrow(pwebsitesTest)

# SPECT heart
# First column - label (0 or 1)
spectTrain = read.csv(file="data/SPECT.train", header=FALSE)
spectTest = read.csv(file="data/SPECT.test", header=FALSE)

# KDD Cup
# Last column has labels
kddcup = read.csv(file="data/kddcup.data_10_percent", header=FALSE)
kddcupTest = read.csv(file="data/corrected", header=FALSE)

# factorize non-numeric columns
factorize(kddcup, 2)
factorize(kddcup, 3)
factorize(kddcup, 4)
factorize(kddcupTest, 2)
factorize(kddcupTest, 3)
factorize(kddcupTest, 4)

# ignore attack kind
# 0 - normal
# 1 - abnormal
kddcup[,42] = kddcup[,42] != 'normal.'
kddcupTest[,42] = kddcupTest[,42] != 'normal.'