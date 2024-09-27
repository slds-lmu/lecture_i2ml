# ---- svm_l_2 ----
# build model for 1-vs-1-ksvm
#
# @param feat [data.frame]
#   features of training data
# @param class [factor]
#   classes of training data
# @param ...
#   parameters for ksvm()
# @return [my.svm.1vs1]
#   list:
#     models: list, values from ksvm()
#     feat: data.frame, as param feat
#     class: data.frame, as param class
#     G: integer(1), number of classes
#     n: integer(1), number of observations


svm_1vs1 = function(feat, class, ...) {

  require(kernlab)

  # check input roughly and save some values

  stopifnot(is.data.frame(feat))
  stopifnot(is.factor(class))

  G = nlevels(class)
  lev = levels(class)
  class.ind = lapply(lev, function(x) which(class == x))

  # build models for every 1-vs-1-combination
  co = combn(G, 2)
  models = vector("list", length=ncol(co))
  for (i in 1:ncol(co)) {
    ind = unlist(class.ind[co[ ,i]])
    y = class[ind][drop=TRUE]
    dat = feat[ind, ]
    models[[i]] = ksvm(y~., data=dat, ...)
  }

  # generate result
  res = list(models=models, feat=feat, class=class, G=G, n=length(class))
  res = structure(res, class = "my.svm.1vs1")
  return(res)
}

# print method for class model for 1-vs-1-ksvm
print.my.svm.1vs1 = function(x) {

  cat("\n Fitted", choose(G, 2), "SVMs for 1-1-Method with", x$G, "classes and",
    x$n, "observations. \n\n")

 cat("Fixed Parameters: \n")
 param = x$models[[1]]@param

 pars.out = paste(names(param), param, sep=" = ")
 pars.out = paste(pars.out, collapse=", ")
 print(pars.out)

 return(invisible(NULL))
}

# predict classes 1-vs-1-ksvm-model
#
# @param mod [my.svm.1vs1]
#   model
# @param newdata [data.frame]
#   features of test data. If NULL, the training data will be used as newdata
# @param new.true [factor]
#   true classes of newdata-observations. If new.true and newdata both are NULL,
#   the classes of the traind data will be uses as new.true
# @param seed [integer(1)]
#   as is set.seed(), for predicting ties at random
# @return [my.svm.1vs1.predict]
#   list:
#     class: factor, predictions
#     error: missclassification error (or NULL, if  new.true ist unknown)
#     table: table of predicted and true classes (or NULL, if  new.true ist unknown)

predict.my.svm.1vs1 = function(mod, newdata=NULL, new.true=NULL,
                               seed=as.numeric(Sys.time())) {

  # predict test data or train data?
  if (is.null(newdata) & is.null(new.true))
    new.true = mod$class
  if (is.null(newdata))
    newdata = mod$feat
  # predict data by all svms and table predictes classes
  all.preds = sapply(mod$models, function(m) predict(m, newdata))
  # number of row is number of training instance, number of column is 10, 5*4/2, which contains the labels for each binary classifier predicition output
  preds = apply(all.preds, 1, function(x) {  # sweep the column(the first dimension), aggreaget the row
    tab = table(x) # counts how many labels wins
    names(tab)[which(tab == max(tab))]
  })

  # if there are ties, predict an random class (of modal values)
  ties = sum(sapply(preds, length) != 1)
  if (ties > 0)
    warning("Ties for ", ties, " observations. Decision will be made by random.")
  ## see ?sample -> Examples -> "sample()'s surprise"
  resample <- function(x) x[sample.int(length(x), size=1)]
  set.seed(seed)
  preds = unlist(sapply(preds, resample))
  names(preds) = NULL
  preds = factor(preds)

  # generate result
  res = list(class=preds, error=NULL, table=NULL)
  if (!is.null(new.true)) {
    # comparism, if some levels are not predicted
    preds.temp = as.character(preds)
    new.true.temp = as.character(new.true)
    res$error = mean(preds.temp != new.true.temp)
    res$table = table(preds, new.true)  # contingency table
  }

  res = structure(res, class = "my.svm.1vs1.predict")
  return(res)
}

# print method for class my.svm.1vs1.predict
print.my.svm.1vs1.predict = function(x) {
  cat("\n Predicted", length(x$class), "observations. \n\n")
  if(!is.null(x$error)) {
    cat("Missclass. error:", x$error, "\n\n")
    print(x$table)
  }
  return(invisible(NULL))
}

## Test with some danom data

library(MASS)
library(mlr)

n.i = 100
G = 5
p = 3
class = factor(rep(letters[1:G], each=n.i)) # 500 class lables, each label repeat 100 times
set.seed(123)
mu = matrix(sample(1:(G*p)), nrow=G)  # 5 rows (number of classes) and p columns
data = apply(mu, 2, function(x) mvrnorm(n.i, mu=x, Sigma=diag(5, G)))  # apply in the direction of row (second dim) which aggregate the column, ie. use the column as the \mu vector of Gaussian. Each function generate a matrix which is tiled to be a column vector 
data = data.frame(data)

mod = svm_1vs1(data, class)
mod
pr = predict(mod)
pr

## compare to mlrs makeMulticlassWrapper()
task = makeClassifTask(data=data.frame(data, class=class), target="class")
lrn = makeMulticlassWrapper("classif.ksvm", mcw.method="onevsone")
mod.mlr = train(lrn, task)
pr.mlr = predict(mod.mlr, task)
# slight differences (heuristic optimization of kernel parameters)
table(pr$class, pr.mlr$data$response)

# compare to kernlabs ksvm(). same here, slight differences:
mod.ksvm = ksvm(class~., data)
pr.ksvm = predict(mod.ksvm)
table(pr$class, pr.ksvm)

## differences caused by heuristics (see ?ksvm -> Arguments -> kpar)
mod.ksvm.1 = ksvm(class~., data)
mod.ksvm.2 = ksvm(class~., data)
mod.ksvm.1@kernelf@kpar
mod.ksvm.2@kernelf@kpar

## constant sigma
mod.ksvm.1 = ksvm(class~., data, kpar=list(sigma=0.5))
mod.ksvm.2 = ksvm(class~., data, kpar=list(sigma=0.5))
mod.ksvm.1@kernelf@kpar
mod.ksvm.2@kernelf@kpar

all(predict(mod.ksvm.1) == predict(mod.ksvm.2))

# last comparism: kernlab vs. mlr:
table(pr.ksvm, pr.mlr$data$response)


