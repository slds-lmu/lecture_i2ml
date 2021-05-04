library(readr)
library(mlr3)
library(mlr3learners)
library(mlr3pipelines)
library(OpenML)
library(ggplot2)
library(gridExtra)

# Only polynomials

set.seed(123)

dd = getOMLDataSet(data.name = "mnist_784")
dd = dd$data
#digits = c(0, 9)
task = TaskClassif$new(backend = dd, target = "class", id = "mnist")
#task = task$filter(rows = which(dd$class %in% digits))

ll = lrn("classif.svm", kernel = "polynomial", cost = 1, type = "C-classification", coef0 = 1)
degrees = 1:3 
svms = lapply(degrees, function(d) {
  ll2 = ll$clone()
  ll2$param_set$values$degree = d
  po("removeconstants") %>>% ll2
  #return(ll2)
})

resa = rsmp("holdout", ratio = 0.01)
g = benchmark_grid(task, svms, resa)
b = mlr3::benchmark(g)
b_a = b$aggregate(msr("classif.ce"))

mnist_test_mmce = data.frame(mmce = b_a$classif.ce, degree = degrees)
save(mnist_test_mmce, file = "data/mnist_svm.RData")

## Polynomial and RBF mixed

degrees = 7
svms = lapply(degrees, function(d) {
  ll2 = ll$clone()
  ll2$param_set$values$degree = d
  po("removeconstants") %>>% ll2
  #return(ll2)
})

gammas = c(0.00105, 1)
rbf_svms = lapply(gammas, function(g) {
  ll2 = ll$clone()
  ll2$param_set$values$gamma = g
  po("removeconstants") %>>% ll2
  #return(ll2)
})

all_svms = append(svms, rbf_svms)

resa = rsmp("holdout", ratio = 0.01)
g = benchmark_grid(task, all_svms, resa)
b = mlr3::benchmark(g)
b_a = b$aggregate(msr("classif.ce"))

b_a

mnist_test_mmce_mixed = data.frame(mmce = b_a$classif.ce)
mnist_test_mmce_mixed$degree = NA
mnist_test_mmce_mixed$degree[1:length(degrees)] = degrees
mnist_test_mmce_mixed$gamma = NA
mnist_test_mmce_mixed$gamma[(length(degrees)+1):(length(degrees) + length(gammas))] =
  gammas

save(mnist_test_mmce_mixed, file = "data/mnist_svm_mixed.RData")
