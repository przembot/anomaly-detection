# iForest algorithm implementation
library(data.tree)


iforestModelGen = function(trainLabels, trainData, treeNum, chi) {
  # forest as set of trees
  forest <- list()
  for (i in 1:treeNum) {
    filterVector <- sample(1:nrow(trainData), chi, replace = FALSE)
    filteredData <- trainData[filterVector,]
    filteredDataLabels <- trainLabels[filterVector]

    maxTreeSize <- ceiling(log2(chi))
    rootNode <- Node$new("Root")
    iTree(rootNode, filteredDataLabels, filteredData, 0, maxTreeSize)
    forest <- c(forest, rootNode)
  }
  model = structure(forest, class="iforestModel")
  return(model)
}


# Tree node has additional fields:
#  - type = {internal, external}
# When internal
#  - splitAtt - name of splitting attribute
#  - splitVal - value which splits tree
# When external
#  - size - number of data subset which is satisfied
#           at given node


# generate iTree with given data
# It's procedure that contructs tree with given root node
# @param trainLabels - vector of labels of given trainData
# @param trainData - training set, with attributes
# @param root - node, which should be now modified
iTree = function(root, trainLabels, trainData, currentSize, limit) {
  # current stop criterium - no attribute that could be split
  # or no data available to split
  # tricky way - because ncol of no col data frame returns null
  if (currentSize >= limit || is.null(ncol(trainData)) 
      || nrow(trainData) == 0) {
    root$type = "external"
    root$size = nrow(trainLabels)
  } else {
    # choose attribute randomly
    # TODO: choose attribute randomly with wages according
    #       to its entropy?
    # attribute list
    Q <- names(trainData)
    selectedQ <- sampleWithoutSurprises(Q)
    # TODO: don't choose attribute which doesn't split the data
    #       (don't choose if every element in data has the same
    #        value of that attribute)
    
    # choose split point randomly
    # NOTE: assuming every attribute values can be compared
    #columnDomain <- as.factor(trainData[,selectedQ])
    #splitPoint <- sampleWithoutSurprises(levels(columnDomain))
    print(trainData[,selectedQ])
    splitPoint <- runif(1, min(trainData[,selectedQ]), max(trainData[,selectedQ]))
    

    # filter data sets
    leftFilter <- which(trainData[,selectedQ] < splitPoint)
    rightFilter <- which(trainData[,selectedQ] >= splitPoint)
    
    # remove given attribute from dataset
    # NOTE: assuming data frame can exists without any column
    trainData <- trainData[ ,!names(trainData) == selectedQ, drop=FALSE]
    
    # construct node and recursive call
    root$type = "internal"
    root$splitAtt = selectedQ
    root$splitVal = splitPoint
    
    # convencion: first child is left, second is right
    leftChild <- root$AddChild("Left")
    rightChild <- root$AddChild("Right")
    iTree(leftChild, trainLabels[leftFilter], trainData[leftFilter,]
         , currentSize+1, limit)
    iTree(rightChild, trainLabels[rightFilter], trainData[rightFilter,]
         , currentSize+1, limit)
  }
}

predict.iforestModel = function(model, newdata) {
  
}

print.iforestModel = function(model) {
  for (tree in model) {
    print(tree, "splitAtt", "splitVal")
  }
}


# Sample usage of iForest implementation
testModel = function() {
  set.seed(1337)
  spectLabels <- spectTrain$V1
  spectData <- spectTrain[,!names(spectTrain) == "V1"]
  iforestModelGen(spectLabels, spectData, 2, 16)
}

# due to R nature, this is required..
sampleWithoutSurprises <- function(x) {
  if (length(x) <= 1) {
    return(x)
  } else {
    return(sample(x, 1))
  }
}