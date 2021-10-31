library(ggplot2)
library(mlr)

set.seed(123L)

plotSVM = function(tsk, par.vals) {
  
  lrn = makeLearner("classif.ksvm", par.vals = par.vals)
  set.seed(123L)
  mod = train(lrn, tsk)
  sv.index = mod$learner.model@SVindex
  df = getTaskData(tsk)
  df = df[ifelse(1:getTaskSize(tsk) %in% sv.index, TRUE, FALSE), ]
  
  set.seed(123L)
  par.set = c(list("classif.ksvm", tsk), par.vals)
  q = do.call("plotLearnerPrediction", par.set)
  q = q + geom_point(data = df, color = "black",
    size = 6, pch = 21L)
  q
}


n = 20
r = runif(n)
a = 2 * pi * runif(n)
a1 = r * sin(a)
a2 = r * cos(a)
r = 1 + runif(n)
a = 2 * pi * runif(n)
b1 = r * sin(a)
b2 = r * cos(a)
x = rbind(matrix(cbind(a1, a2), n, 2),matrix(cbind(b1, b2), n, 2))
y = as.factor(c(rep(1,n),rep(-1,n)))
df = data.frame(x, y = y)

tsk = makeClassifTask(data = df, target = 'y')

plotSVM(tsk, list(kernel = "rbfdot", C = 1, sigma = 50))
ggsave("figure_man/kernels/rbf_sig50.pdf")

plotSVM(tsk, list(kernel = "rbfdot", C = 1, sigma = 0.01))
ggsave("figure_man/kernels/rbf_sig01.pdf")


s = sigest(y ~ . , data = df)
s = mean(c(s[1], s[3]))
plotSVM(tsk, list(kernel = "rbfdot", C = 1, sigma = s) )
ggsave("figure_man/kernels/rbf_sigest.pdf")

