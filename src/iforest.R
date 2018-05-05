# iForest algorithm implementation
library(data.tree)
library(caret)

# @param trainData - training data without labels
# @param treeNum - number of iTrees in iForest
# @param chi - subsampling size
# @param threshold - activation treshold of anomaly score
#                    (set greater than 0.5)
iforestModelGen = function(trainData, treeNum, chi, threshold) {
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
  model$threshold = threshold
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
    #print(anomalyScore(model, sample))
    anomalyScore(model, sample) > model$threshold
  })
}


anomalyScore = function(model, sample) {
  # evaluate path lengths in all trees in model
  pathlengths <- sapply(model$iforest, function(itree) {
    pathLength(itree, sample, model$chi, model$limit, 0)
  })
  
  2^(-mean(pathlengths)/cFunc(model$chi))
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
    e + cFunc(node$size)
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
cFunc = function(n) {
  if (n > 2) {
    2*harmNumber(n-1) - 2*(n-1)/n
  } else if (n == 2) {
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
  set.seed(1337)
  
  # dataset for training - without labels
  # using only samples which are 'normal'
  spectData <- spectTrain[which(spectTrain[,"V1"] == 1),]
  #spectData <- spectTrain
  spectData <- spectData[,!names(spectData) == "V1"]
  
  # parameters for model are - dataset, number of trees, chi variable, threshold
  model <- iforestModelGen(spectData, 50, 32, 0.65)
  # print all trees
  #print(model)
  
  # remove labels from test data
  spectTestData <- spectTest[,!names(spectTest) == "V1"]
  # but keep them to evaluate quality
  spectTestLabels <- spectTest$V1
  # and also swap 1 with 0, because anomaly is labeled as 0
  # in spect data set
  spectTestLabels <- spectTestLabels == 0
  
  # prediction - true if anomaly, false otherwise
  predictionResult <- predict(model, spectTestData)
  
  confusionMatrix(as.factor(spectTestLabels)
                 ,as.factor(predictionResult))
}