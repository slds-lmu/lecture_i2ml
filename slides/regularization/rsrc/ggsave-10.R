
library(knitr)
library(mlr)
library(mlbench)
library(ggplot2)
library(BBmisc)
library(reshape)

set_parent("../style/preamble.Rnw")

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

####################################################################



