# Load all available data into R
library(farff)

# Phishing websites
# Last column has labels
pwebsites = readARFF("data/PW.arff")

# SPECT heart
# First column - label (0 or 1)
spectTrain = read.csv(file="data/SPECT.train", header=FALSE)
spectTest = read.csv(file="data/SPECT.test", header=FALSE)

# KDD Cup
# Last column has labels
kddcup = read.csv(file="data/kddcup.data_10_percent", header=FALSE)


# TODO: separate train/test sets to be used everywhere?