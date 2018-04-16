# Load all available data into R
library(farff)

# Phishing websites
pwebsites = readARFF("data/PW.arff")

# SPECT heart
spectTrain = read.csv(file="data/SPECT.train", header=FALSE)
spectTest = read.csv(file="data/SPECT.test", header=FALSE)

# KDD Cup
# TODO: assign names/labels?
kddcup = read.csv(file="data/kddcup.data_10_percent", header=FALSE)


# TODO: separate train/test sets
