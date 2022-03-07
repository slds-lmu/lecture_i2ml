library(ggplot2)
library(mlr)

plotSVM <- function(tsk, par.vals) {
  set.seed(123L)
  par.set <- c(list("classif.svm", tsk), par.vals)
  q <- do.call("plotLearnerPrediction", par.set) +
    scale_fill_viridis(end = 0.9, discrete = TRUE)
  q
}

set.seed(123L)
makeSimulatedTask <- function(size) {
  cluster.size <- floor(size / 3)
  x1 <- c(rnorm(cluster.size, mean = - 1.5), rnorm(cluster.size/2),
          rnorm(cluster.size, mean = 1.5))
  x2 <- c(rnorm(cluster.size, mean = - 1), rnorm(cluster.size/2),
          rnorm(cluster.size, mean = 1))
  y <- factor(c(rep("a", times = cluster.size), sample(c("a", "b"),
                                                       size = cluster.size/2, replace = TRUE), rep("b", times = cluster.size)))
  sim.df <- data.frame(x1 = x1, x2 = x2, y = y)
  makeClassifTask("simulated example", data = sim.df, target = "y")
}