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


exampleUsage = function() {
  sens <- c(1, 5, 50, 60)
  spec <- c(2, 6, 55, 80)

  data <- data.frame(sens, spec)
  colnames(data) <- c("sens", "spec")
  graphROC(data)
}