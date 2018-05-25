# use JIT
require(compiler)
enableJIT(3)

# Load all the data..
source("src/load.R")

# for determinisic results, set seed to const value
set.seed(31337)

source("src/knn.R")
knnMain()

source("src/svm.R")
svmMain()

source("src/rf.R")
rfMain()

source("src/iforest.R")
iforestMain()