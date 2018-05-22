# iForest algorithm implementation
library(data.tree)
library(caret)

library(pROC)

# @param trainData - training data without labels
# @param treeNum - number of iTrees in iForest
# @param chi - subsampling size
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
    anomalyScore(model, sample) # > model$threshold
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


roundDown = function(x) {
  2^floor(log2(x))
}

# @param trainData - training data without labels
# @param testData - test data without labels
# @param testDataLabels - vector of test data labels
# Generates ROC curves plot
generateRaport = function(trainData, testData, testDataLabels, chiVals) {
  treeNums = c(10, 20, 30)
  sizeTrain = nrow(trainData)
  if(missing(chiVals)){
    chiVals = sapply(c(sizeTrain, sizeTrain/2), roundDown)
  }
  lineColors = rainbow(length(treeNums)*length(chiVals))
  
  for (i in 1:length(treeNums)) {
    for (j in 1:length(chiVals)) {
      evaluate(trainData, testData, testDataLabels, treeNums[[i]], chiVals[[j]],
               i==1&&j==1, lineColors[[(i-1)*length(chiVals)+j]])
    }
  }
}

# @param firstplot - boolean, true when it's time to create plot
# @param color - color of the curve
evaluate = function(trainData, testData, testDataLabels, treeNum, chi, firstplot, color) {
  model <- iforestModelGen(trainData, treeNum, chi)

  prediction <- predict(model, testData)

  rocObj <- roc(response = testDataLabels,
                predictor = prediction,
                percent=TRUE)

  # print the best threshold for given parameters
  cat("treeNum:",treeNum,"chi:",chi,"\n")
  print(coords(rocObj, "best"))

  plot(rocObj,
       add=!firstplot,
       grid=TRUE,
       col=color,
       # increase precision
       print.thres.pattern="%.3f (%.1f%%, %.1f%%)",
       print.thres="best",
       main="ROC curves")
}

main = function() {
  # data preparation

  # training set
  spectData <- spectTrain[which(spectTrain[,"V1"] == 1),]
  spectData <- spectData[,!names(spectData) == "V1"]
  
  # test set
  spectTestData <- spectTest[,!names(spectTest) == "V1"]
  spectTestLabels <- spectTest$V1
  # and also swap 1 with 0, because anomaly is labeled as 0
  # in spect data set
  spectTestLabels <- spectTestLabels == 0
  
  #set.seed(1337)
  generateRaport(spectData, spectTestData, spectTestLabels)
  
  phishingData <- pwebsitesTrain[which(pwebsitesTrain[,"Result"] == 1),]
  phishingData <- phishingData[,!names(phishingData) == "Result"]
  
  phishingTestData <- pwebsitesTest[,!names(pwebsitesTest) == "Result"]
  phishingTestLabels <- pwebsitesTest$Result
  generateRaport(phishingData, phishingTestData, phishingTestLabels)
  
  kddData <- kddcup[which(kddcup[,"V42"] == T),]
  kddData <- kddData[,!names(kddData) == "V42"]
  kddTestData <- kddcupTest[,!names(kddcupTest) == "V42"]
  kddTestLabels <- kddcupTest$V42
  chiVals = c(256, 512, 1024)
  generateRaport(kddData, kddTestData, kddTestLabels, chiVals)
}
