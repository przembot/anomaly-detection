# @param data - data frame with "sens", "spec" attributes
# @return graph with all points marked
graphROC = function(data) {

  sens <- c(100, 0)
  spec <- c(0, 100)

  legendPoints <- data.frame(sens, spec)
  colnames(legendPoints) <- c("sens", "spec")

  plot(legendPoints,
     main="ROC",
     xlim=c(100, 0),
     ylim=c(0, 100),
     xlab="Sensitivity (%)",
     ylab="Specificity (%)",
     asp=1,
     type="o",
     pch=19,
     col="black")

  grid(nx = 10, ny = 10)

  lines(c(100, 0), c(0, 100), col="black")
  
  points(data, col=rainbow(nrow(data)), pch=19)
}

evaluatePerformance = function(testDataLabels, prediction) {
  quality <- mean(prediction == testDataLabels)
  cat("quality:",quality,"\n")
  
  dataIn <- as.factor(prediction)
  levels(dataIn) <- c(0, 1)
  refIn <- as.factor(testDataLabels)
  levels(refIn) <- c(0, 1)
  
  perf <- confusionMatrix(data = dataIn,
                          reference = refIn,
                          positive = "1")
  
  print(perf)
  sens = perf$table[2,2]*100/(perf$table[1,2]+perf$table[2,2])
  spec = perf$table[1,1]*100/(perf$table[1,1]+perf$table[2,1])
  
  c(sens, spec)
  
}


exampleUsage = function() {
  sens <- c(1, 5, 50, 60)
  spec <- c(2, 6, 55, 80)

  data <- data.frame(sens, spec)
  colnames(data) <- c("sens", "spec")
  graphROC(data)
}