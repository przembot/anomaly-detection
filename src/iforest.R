# iForest algorithm implementation
library(data.tree)


iforestModelGen = function(trainData, treeNum, chi) {
  # forest as set of trees
  forest <- list()
  for (i in 1:treeNum) {
    x <- sample(trainData, chi, replace = FALSE)
    forest <- c(forest, iTree(x))
  }
  model = structure(forest, class="iforestModel")
  return(model)
}

# generate iTree with given data
iTree = function(trainData) {
  
}

predict.iforestModel = function(model, newdata) {
  
}