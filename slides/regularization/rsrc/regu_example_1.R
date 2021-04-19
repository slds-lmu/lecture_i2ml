library(mlr)
library(BBmisc)
library(data.table)

set.seed(123)

task = bh.task
task = dropFeatures(task, c("chas", "nox", "rm"))
featnames = getTaskFeatureNames(task)

compute_coef_paths = function(task, lambda_name, lambda_seq) {
  lrn = makeLearner("regr.penalized", trace = FALSE, lambda1 = 0, lambda2 = 0)
  path = list()
  for (i in seq_along(lambda_seq)) {
    lamval = lambda_seq[[i]]
    pv = namedList(lambda_name, lamval)
    lrn2 = setHyperPars(lrn, par.vals = pv)
    m1 = train(lrn2, task)
    mm1 = getLearnerModel(m1)
    cc = coefficients(mm1)
    cc = as.list(cc)
    cc$lambda = lamval
    path[[i]] = cc
  }
  path = rbindlist(path, fill = TRUE)
  path[is.na(path)] = 0
  ps = makeParamSet(
    makeDiscreteParam(id = lambda_name, values = lambda_seq)
  )
  ctrl = makeTuneControlGrid()
  tr = tuneParams(lrn, task, cv3, par.set = ps, control = ctrl, show.info = FALSE)
  cv_lam = as.data.frame(tr$opt.path)[, c(lambda_name, "mse.test.mean")]
  colnames(cv_lam) = c("lambda", "mse")
  cv_lam$lambda = as.numeric(as.character(cv_lam$lambda))
  list(path = path, cv_lam = cv_lam)
}

lambda_seq = 2^seq(-10, 20, length.out = 50)
path_l1 = compute_coef_paths(task, "lambda1", lambda_seq)
path_l2 = compute_coef_paths(task, "lambda2", lambda_seq)

save2("regu_example_1.RData", path_l1 = path_l1, path_l2 = path_l2, featnames = featnames, lambda_seq = lambda_seq)

