library(reshape2)
library(mvtnorm)
library(gridExtra)

################################################################################
# add CIM2 scheme

library(ggplot2)
library(viridis)
theme_set(theme_minimal(base_size = 17))
scale_c_d <- scale_colour_discrete <- scale_color_discrete <-
  function(...) viridis::scale_color_viridis(..., end = .9, discrete = TRUE, drop = TRUE)
scale_f_d <- scale_fill_discrete <-
  function(...) viridis::scale_fill_viridis(..., end = .9,  discrete = TRUE, drop = TRUE)
scale_c <- scale_colour_continuous <- scale_color_continuous <-
  function(...) viridis::scale_color_viridis(..., end = .9)
scale_f <- scale_fill_continuous <-
  function(...) viridis::scale_fill_viridis(..., end = .9)

pal_2 <- viridisLite::viridis(2, end = .9)
pal_3 <- viridisLite::viridis(3, end = .9)
pal_4 <- viridisLite::viridis(4, end = .9)
pal_5 <- viridisLite::viridis(5, end = .9)

################################################################################
plotSVM = function(tsk, par.vals) {
  
  lrn = makeLearner("classif.ksvm", par.vals = par.vals)
  set.seed(123L)
  mod = train(lrn, tsk)
  sv.index = mod$learner.model@SVindex
  df = getTaskData(tsk)
  df = df[ifelse(1:getTaskSize(tsk) %in% sv.index, TRUE, FALSE), ]
  
  set.seed(123L)
  par.set = c(list("classif.ksvm", tsk), par.vals)
  q = do.call("plotLearnerPrediction", par.set) + scale_f_d()
  #q = q + geom_point(data = df, color = "black",
  #  size = 6, pch = 21L)
  q
}
set.seed(123L)
makeSimulatedTask = function(size) {
  cluster.size = floor(size / 3)
  x1 = c(rnorm(cluster.size, mean = - 1.5), rnorm(cluster.size/2),
         rnorm(cluster.size, mean = 1.5))
  x2 = c(rnorm(cluster.size, mean = - 1), rnorm(cluster.size/2),
         rnorm(cluster.size, mean = 1))
  y = factor(c(rep("a", times = cluster.size), sample(c("a", "b"),
                                                      size = cluster.size/2, replace = TRUE), rep("b", times = cluster.size)))
  sim.df = data.frame(x1 = x1, x2 = x2, y = y)
  makeClassifTask("simulated example", data = sim.df, target = "y")
}

############################################################################

library(FNN)
library(purrr)

dist_p <- function(dims, n_per_dim = 1e4, k = 1) {
  x <- matrix(runif(dims * n_per_dim), ncol = dims)
  dist <- as.vector(dist(x))
  dist_nn <- FNN::knn.dist(x, k = k)
  data.frame(dim = dims,
             min = min(dist),
             mean = mean(dist),
             max = max(dist),
             mean_nn = mean(dist_nn),
             max_nn = max(dist_nn))
}