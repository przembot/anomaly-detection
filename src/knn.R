# Module which uses k-nn classifier to detect anomalies
library(class)
library(caret)
library(pROC)

# Currently, training set is the model,
# but this set can be reduced by 'condense'

evaluatePerformance = function(testDataLabels, prediction, k, firstplot, color){
  cnfMx <- confusionMatrix(data = prediction,
                        reference = testDataLabels)
  # print(cnfMx)
  FPR = cnfMx$table[1,2]/(cnfMx$table[2,1]+cnfMx$table[2,2])
  quality <- mean(prediction == testDataLabels)
  # ROC
  rocObj <- roc(response = testDataLabels,
                predictor = as.numeric(prediction),
                percent=TRUE)
  xy = coords(rocObj, "best")
  plot(rocObj,
       add=!firstplot,
       grid=TRUE,
       xlim=if(rocObj$percent){c(100, 0)} else{c(1, 0)},
       col=color,
       # print.thres="best",
       print.auc = T,
       print.auc.y = k*2,
       print.auc.pattern = paste(sprintf("k=%d, ",k),"AUC:%.1f%%"),
       main="ROC",
       type="p")
  # Add a legend
  # legend("bottomright", legend=sprintf("k:%d, auc:%f",k,auc(rocObj),"\n"),fill=color, col=color, cex = 0.8)
  ev = c(k, quality, xy[2:3], FPR)
  names(ev)<- c("k", "quality", "sensitivity", "specificity", "fall-out")
  ev <- as.data.frame(t(ev))
  return(ev)
}

evaluate = function(trainData, testData, labelsColName, k, firstplot, color){
  # classify
  labelsColNb = which( colnames(trainData)==labelsColName )
  result <- knn(trainData[,-labelsColNb], 
                testData[,-labelsColNb], 
                trainData[,labelsColName], 
                k = k, 
                prob=FALSE)
  testDataLabels = as.factor(testData[,labelsColName])
  ev <- evaluatePerformance(testDataLabels, result, k, firstplot, color)
  return(ev)
}

chooseBestParameter = function(trainData, testData, labelsColName, k_values){
  if(missing(k_values)){
    k_values = c(1,3,5,7,9)
  }
  lineColors = rainbow(length(k_values))
  qualities = data.frame()
  # choose best k value
  for (i in 1:length(k_values)) {
    qualities = rbind(qualities, evaluate(trainData,
                             testData, 
                             labelsColName, 
                             k_values[[i]], 
                             i==1,
                             lineColors[[i]]))
  }
  print(qualities)
  # best result based on quality value
  best_result = qualities[qualities$quality==max(qualities$quality),]
  return(best_result$k)
}

generateRaport = function(trainData, testData, labelsColName, parameter_value, iterations) {
  # for given k count mean value of quality
  lineColors = rainbow(iterations)
  qualities = data.frame()
  for (i in 1:iterations) {
    qualities = rbind(qualities, evaluate(trainData,
                             testData, 
                             labelsColName, 
                             parameter_value, 
                             i==1,
                             lineColors[[i]]))
  }
  print(qualities)
  mean_quality = c(mean(qualities[,2]), mean(qualities[,3]), mean(qualities[,4]))
  return(mean_quality)
}


knnMain = function () {
  best_value = chooseBestParameter(spectTrain, spectTest, "V1")
  generateRaport(spectTrain, spectTest, "V1", 3, 20)
  dev.copy(png,'./docs/images/spect_knn.png')
  dev.off()

  best_value = chooseBestParameter(pwebsitesTrain, pwebsitesTest, "Result")
  generateRaport(pwebsitesTrain, pwebsitesTest, "Result", best_value, 20)
  dev.copy(png,'./docs/images/pweb_knn.png')
  dev.off()

  # best_value = chooseBestParameter(kddcup, kddcupTest, "V42")
  # note: without ties randomisation, kddcup will fail to classify
  # generateRaport(kddcup, kddcupTest, "V42", best_value, 20)
  #dev.copy(png,'./docs/images/kdd_knn.png')
  #dev.off()
}