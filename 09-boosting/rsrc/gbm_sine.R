library(gbm)
library(reshape2)
library(ggplot2)
library(gridExtra)

doPlot = function(sd, shrinkage) {
  set.seed(1)
  n = 30
  x = seq(0, 3*pi/2, length.out = n)
  y = sin(x) + rnorm(n, sd = sd)
  data = data.frame(x = x, y = y)
  n.trees = 1000

  model = gbm(y ~ ., data = data, distribution = "gaussian",
    n.trees = n.trees, verbose = FALSE,
    interaction.depth = 1, shrinkage = shrinkage,
    bag.fraction = 1, n.minobsinnode = 2
  )

  iters = c(1, 10, 20, 1000)
  data.pred = data.frame(x = data$x)
  for (i in iters) {
    data.pred = cbind(data.pred, predict(model, n.trees = i))
  }
  colnames(data.pred) = c("x", iters)
  data.pred = melt(data.pred, id.vars = "x", variable.name = "M", value.name = "y")
  ggplot() + geom_point(data = data, aes(x = x, y = y), alpha= .5) +
    geom_step(data = data.pred, aes(x = x, y = y, col = M)) +
    ggtitle(sprintf("y = sin(x) + N(0, %.2f)", sd))

}
# # example:
# p1 = doPlot(sd = 0.0, shrinkage = 1)
# p2 = doPlot(sd = 0.1, shrinkage = 1)
# grid.arrange(p1, p2, nrow = 1, widths = c(0.3, 0.3))
