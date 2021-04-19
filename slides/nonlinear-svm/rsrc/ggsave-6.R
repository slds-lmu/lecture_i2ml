
plotSVM = function(tsk, par.vals) {

  lrn = makeLearner("classif.svm", par.vals = par.vals)
  set.seed(123L)
  mod = train(lrn, tsk)
  sv.index = mod$learner.model$index
  df = getTaskData(tsk)
  df = df[ifelse(1:getTaskSize(tsk) %in% sv.index, TRUE, FALSE), ]

  set.seed(123L)
  par.set = c(list("classif.svm", tsk), par.vals)
  q = do.call("plotLearnerPrediction", par.set) + scale_f_d()+
  xlab(expression(x[1]))+
  ylab(expression (x[2]))
  #q = q + geom_point(data = df, color = "black",
  #  size = 6, pch = 21L)
  q
}

############################################################################

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

## Define two task: one almost linear and one spirals
set.seed(123L)
n = 120
tsk_lin = makeSimulatedTask(n)

tsk_spiral <- convertMLBenchObjToTask("mlbench.spirals",n=300, cycles = 1, sd = 0.12)



############################################################################


plotSVM(tsk_lin, list(kernel = "radial", cost = 0.035, gamma = 1))


############################################################################

plotSVM(tsk_spiral, list(kernel = "radial", cost = 0.035, gamma = 1))


############################################################################

plotSVM(tsk_lin, list(kernel = "radial", cost = 100, gamma = 1))


############################################################################

plotSVM(tsk_spiral, list(kernel = "radial", cost = 100, gamma = 1))


############################################################################

plotSVM(tsk_spiral, list(kernel = "radial", cost = 1, gamma = 1))
plotSVM(tsk_spiral, list(kernel = "radial", cost = 1000, gamma = 1))


############################################################################

plotSVM(tsk_spiral, list(kernel = "radial", cost = 0.1, gamma = 0.1))
plotSVM(tsk_spiral, list(kernel = "radial", cost = 100, gamma = 20))


plotSVM(tsk_spiral, list(kernel = "polynomial", cost = 1, coef0 = 1, degree = 1))
plotSVM(tsk_spiral, list(kernel = "polynomial", cost = 10, coef0 = 1, degree = 3))



plotSVM(tsk_spiral, list(kernel = "polynomial", cost = 0.01, coef0 = 1, degree = 3))
plotSVM(tsk_spiral, list(kernel = "polynomial", cost = 10, coef0 = 1, degree = 7))



gg = sigest(classes~., data = getTaskData(tsk_spiral))
plotSVM(tsk_spiral, list(kernel = "radial", cost = 1, gamma = gg[2L]))



set.seed(123L)
p_lin <- plotSVM(tsk_lin, list(kernel = "radial", 
                  cost = 1, 
                  gamma = 0.4148496))


