# iForest algorithm implementation
library(data.tree)


iforestModelGen = function(trainData, treeNum, chi) {
  # forest as set of trees
  forest <- list()
  maxTreeSize <- ceiling(log2(chi))
  for (i in 1:treeNum) {
    filterVector <- sample(1:nrow(trainData), chi, replace = FALSE)
    filteredData <- trainData[filterVector,]

    rootNode <- Node$new("Root")
    iTree(rootNode, filteredData, 0, maxTreeSize)
    forest <- c(forest, rootNode)
  }
  model <- NULL
  model$chi = chi
  model$n = nrow(trainData)
  model$limit = maxTreeSize
  model$iforest = forest
  class(model) <- "iforestModel"
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
# @param trainData - training set, with attributes
# @param root - node, which should be now modified
iTree = function(root, trainData, currentSize, limit) {
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

      iTree(leftChild, trainData[leftFilter,]
           , currentSize+1, limit)
      iTree(rightChild, trainData[rightFilter,]
           , currentSize+1, limit)
    }
  }
}

# @return vector of booleans, where true means anomaly
predict.iforestModel = function(model, newdata) {
  apply(newdata, 1, function(sample) {
    anomalyScore(model, sample) > 0.5
  })
}


anomalyScore = function(model, sample) {
  # evaluate path lengths in all trees in model
  pathlengths <- sapply(model$iforest, function(itree) {
    pathLength(itree, sample, model$chi, model$limit, 0)
  })
  
  2^(-mean(pathlengths)/cFunc(model$chi, model$chi))
}

print.iforestModel = function(model) {
  for (tree in model$iforest) {
    print(tree, "splitAtt", "splitVal", "size")
  }
}


# @param tree - iTree
# @param sample - data sample
# @param limit - search depth limit
# @param e - current depth (start with 0)
# @return path length - as defined in paper
pathLength = function(node, sample, chi, limit, e) {
  # second condition should not be ever met - as tree
  # size is cut according to chi variable
  if (node$type == "external" || e >= limit) {
    e + cFunc(chi, node$size)
  } else {
    attrName <- node$splitAtt
    splitVal <- node$splitVal
    x <- sample[attrName]
    
    if (x < splitVal) {
      # go left
      pathLength(node$children[[1]], sample, chi, limit, e+1)
    } else {
      # go right
      pathLength(node$children[[2]], sample, chi, limit, e+1)
    }
  }
}

# c function from Equation 1 from paper
cFunc = function(chi, n) {
  if (chi > 2) {
    2*harmNumber(chi-1) - 2*(chi-1)/n
  } else if (chi == 2) {
    1
  } else {
    0
  }
}

# Harmonic number
harmNumber = function(x) {
  log(x)+0.5772156649
}

# check if values in given column
# have only one value
attrSplitsData = function (data, attrName) {
  colData <- data[,attrName]
  min(colData) != max(colData)
}


# Example usage of iForest implementation
exampleUsage = function() {
  # for deterministic testing, set const seed
  #set.seed(1337)
  
  # dataset for training - without labels
  spectData <- spectTrain[,!names(spectTrain) == "V1"]
  
  # parameters for model are - dataset, number of trees, chi variable
  model <- iforestModelGen(spectData, 10, 16)
  print(model)
  
  # remove labels from test data
  spectTestData <- spectTest[,!names(spectTest) == "V1"]
  # but keep them to evaluate quality
  spectTestLabels <- spectTest$V1
  
  # prediction - true if anomaly, false otherwise
  predictionResult <- predict(model, spectTestData)
  
  mean(spectTestLabels == predictionResult)
}