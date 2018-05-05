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
      || nrow(trainData) <= 1) {
    root$type = "external"
    root$size = nrow(trainData)
  } else {
    # attribute list
    Q <- names(trainData)
    
    # choose attribute randomly
    # possible enhancement? - choose attribute 
    # randomly with wages according to its entropy?
    randomPerm <- sample(Q)
    selectedQ <- NULL
    for (attrName in randomPerm) {
      if (attrSplitsData(trainData, attrName)) {
        selectedQ <- attrName
        break()
      }
    }
    
    # if data is already divided, create external node
    if (is.null(selectedQ)) {
      root$type = "external"
      root$size = nrow(trainData)
    } else {
    
      # choose split point randomly
      # NOTE: assuming every attribute values can be compared
      #columnDomain <- as.factor(trainData[,selectedQ])
      #splitPoint <- sampleWithoutSurprises(levels(columnDomain))
      splitPoint <- runif(1, min(trainData[,selectedQ]), max(trainData[,selectedQ]))
    
      # filters of data sets
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
}

predict.iforestModel = function(model, newdata) {
  
}

print.iforestModel = function(model) {
  for (tree in model) {
    print(tree, "splitAtt", "splitVal", "size")
  }
}


# Sample usage of iForest implementation
testModel = function() {
  set.seed(1337)
  spectLabels <- spectTrain$V1
  spectData <- spectTrain[,!names(spectTrain) == "V1"]
  model <- iforestModelGen(spectLabels, spectData, 2, 16)
  print(model)
  
  # choose first generated tree for example path length calculation
  randomITree <- model[[1]]
  sample <- spectTest[1, , drop=FALSE]
  sampleNoLabel <- sample[,!names(spectTrain) == "V1"]
  pathLength(randomITree, sampleNoLabel, 4, 0)
}

# @param tree - iTree
# @param sample - data sample
# @param limit - search depth limit
# @param e - current depth (start with 0)
# @return path length - as defined in paper
pathLength = function(node, sample, limit, e) {
  if (node$type == "external" || e >= limit) {
    # TODO: get Equation 1 function
    e + node$size
  } else {
    attrName <- node$splitAtt
    splitVal <- node$splitVal
    x <- sample[,attrName]
    
    # use for debugging tree traversal
    # print(cat("attrName", attrName, "splitVal", splitVal, "x_sample", x))
    
    if (x < splitVal) {
      # go left
      pathLength(node$children[[1]], sample, limit, e+1)
    } else {
      # go right
      pathLength(node$children[[2]], sample, limit, e+1)
    }
  }
}

# check if values in given column
# have only one value
attrSplitsData = function (data, attrName) {
  colData <- data[,attrName]
  min(colData) != max(colData)
}