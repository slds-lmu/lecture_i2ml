
set.seed(123L)
x <- cbind(
  c(2,3,4,5,6,0,1,2,3,1,2,3),
  c(0,0,0,0,0,0,1,2,3,-1,-2,-3))
y <- c(-1,-1,-1,-1,-1,1,1,1,1,1,1,1)
df <- data.frame (x = x, y = as.factor(y))
tsk = makeClassifTask(data = df, target = 'y')

plotSVM = function(tsk, par.vals) {

  lrn = makeLearner("classif.svm", par.vals = par.vals)
  set.seed(123L)
  mod = train(lrn, tsk)
  sv.index = mod$learner.model$index
  df = getTaskData(tsk)
  df = df[ifelse(1:getTaskSize(tsk) %in% sv.index, TRUE, FALSE), ]

  set.seed(123L)
  par.set = c(list("classif.svm", tsk), par.vals)
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

## Define two task: one almost linear and one spirals
set.seed(123L)
n = 120
tsk_lin = makeSimulatedTask(n)

tsk_spiral <- convertMLBenchObjToTask("mlbench.spirals",n=300, cycles = 1, sd = 0.12)

############################################################################


set.seed(123L)

n = 200
tsk = makeSimulatedTask(n)

p_lin <-plotSVM(tsk_lin, list(kernel = "polynomial", degree  = 1, coef0 = 1))
p_spiral <-plotSVM(tsk_spiral, list(kernel = "polynomial", degree  = 1, coef0 = 1))



############################################################################
p_lin

############################################################################
p_spiral

############################################################################

set.seed(1234L)
p_lin <- plotSVM(tsk_lin, list(kernel = "polynomial", degree  = 3, coef0 = 1))
p_spiral <- plotSVM(tsk_spiral, list(kernel = "polynomial", degree  = 3,coef0 = 1))


############################################################################

set.seed(1L)
p_lin <- plotSVM(tsk_lin, list(kernel = "polynomial", degree  = 9, coef0 = 1))
p_spiral <- plotSVM(tsk_spiral, list(kernel = "polynomial", degree  = 9,  coef0 = 1))



############################################################################

set.seed(1235L)
p_lin <- plotSVM(tsk_lin, list(kernel = "polynomial", degree  = 3, coef0 = 0))

p_spiral <- plotSVM(tsk_spiral, list(kernel = "polynomial", degree  = 3, coef0 = 0))


############################################################################