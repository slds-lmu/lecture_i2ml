library(mlr)
library(pensim)
library(ggplot2)
library(gridExtra)
library(MASS)

set.seed(19873)
n <- 100    # Number of observations
p <- 50     # Number of predictors included in model
CovMatrix <- outer(1:p, 1:p, function(x,y) {.7^abs(x-y)})
x <- mvrnorm(n, rep(0,p), CovMatrix)
y <- 10 * apply(x[, 1:2], 1, sum) +
  5 * apply(x[, 3:4], 1, sum) +
  apply(x[, 5:14], 1, sum) +
  rnorm(n)


dd = as.data.frame(x)
dd$y = y
task = makeRegrTask(data = dd, target = "y")


get_pen_coefs = function(task, alpha, lam) {
  featnames = getTaskFeatureNames(task)
  lrn = makeLearner("regr.glmnet", alpha = alpha, lambda = lam)
  m = train(lrn, task)
  mm = getLearnerModel(m)
  cc1 = as.matrix(coef(mm))[,1]
  return(abs(cc1))
}

compute_cv = function(task, alpha, lambda_seq) {
  lrn = makeLearner("regr.glmnet", alpha = alpha)
  ps = makeParamSet(
    makeDiscreteParam("lambda", values = lambda_seq)
  )
  ctrl = makeTuneControlGrid()
  tr = tuneParams(lrn, task, cv3, par.set = ps, control = ctrl, show.info = FALSE)
  cv_lam = as.data.frame(tr$opt.path)[, c("lambda", "mse.test.mean")]
  colnames(cv_lam) = c("lambda", "mse")
  cv_lam$lambda = as.numeric(as.character(cv_lam$lambda))
  cv_lam
}

lams = c(0.01, 100)
cc_l2_1 = get_pen_coefs(task, alpha = 0, lam = lams[1])
cc_l2_2 = get_pen_coefs(task, alpha = 0, lam = lams[2])
cc_l1_1 = get_pen_coefs(task, alpha = 1, lam = lams[1])
cc_l1_2 = get_pen_coefs(task, alpha = 1, lam = lams[2])


lambda_seq = 2^seq(-20, 1, length.out = 50)
cv_l1 = compute_cv(task, alpha = 1, lambda_seq)
cv_l2 = compute_cv(task, alpha = 0, lambda_seq)

save2("regu_example_2.RData", lams, lambda_seq,
      cc_l2_1, cc_l2_2, cc_l1_1, cc_l1_2,
      cv_l1, cv_l2)

