
library(mlr3misc)
library(mvtnorm)
library(mlr3)
library(mlr3learners)
library(mlr3viz)
library(ggplot2)
library(gridExtra)

set.seed(600000)
n = 100000

mu1 = c(0, 3)
mu2 = c(3, 0)
s1 = matrix(c(1, 0.1, 0.1, 2), 2, 2, byrow = TRUE)
s2 = matrix(c(30, 0.3, 0.3, 1), 2, 2, byrow = TRUE)
d1 = as.data.table(rmvnorm(n = n/2, mean = mu1, sigma = s1))
d1$class = 1
d2 = as.data.table(rmvnorm(n = n/2, mean = mu2, sigma = s2))
d2$class = 2
dd = rbind(d1, d2)
dd$class = as.factor(dd$class)
oo = sample(n)
dd = dd[oo,]
task = TaskClassif$new("2dgauss", dd, target = "class")

trainsize = 200
trainset = 1:trainsize
testset = (trainsize+1):n

l1 = lrn("classif.qda", predict_type = "prob")
l2 = lrn("classif.log_reg", predict_type = "prob")
l3 = lrn("classif.svm", type = "C-classification", predict_type = "prob", 
  kernel = "radial", gamma = 99, cost = 1)

l1$train(task)
r1 = range(dd[trainset,]$V1)
r2 = range(dd[trainset,]$V2)
r1seq = seq(r1[1], r1[2], length.out = 200)
r2seq = seq(r2[1], r2[2], length.out = 200)
d_grid = expand.grid(V1 = r1seq, V2 = r2seq)
pred_true = as.data.table(l1$predict_newdata(d_grid))
d_grid$prob = pred_true$prob.1 
true_decb = d_grid[d_grid$prob > 0.47 & d_grid$prob < 0.53,]


make_plot = function(ll, file_postfix) {
  ll$train(task, row_ids = trainset)
  pred_train = ll$predict(task, row_ids = trainset)
  trainerr = pred_train$score(msr("classif.ce"))
  pred_test = ll$predict(task, row_ids = testset)
  testerr = pred_test$score(msr("classif.ce"))
  fname = sprintf("../figure/eval_ofit_1%s.pdf", file_postfix)
  task_train = task$filter(rows = trainset)
  pl = plot_learner_prediction(ll, task) + guides(shape = FALSE, alpha = FALSE)
  pl = pl + ggtitle(sprintf("TrainErr=%.2f;    TestErr=%.2f", trainerr, testerr))
  pl = pl + geom_point(data = true_decb, alpha=0.5, size=0.2)
  ggsave(plot = pl, filename = fname, width = 8, height = 6)
  return(pl)
}

p1 = make_plot(l1, file_postfix = "a")
p2 = make_plot(l2, file_postfix = "u")
p3 = make_plot(l3, file_postfix = "o")

#grid.arrange(p1, p2, p3)
#print(p2)

