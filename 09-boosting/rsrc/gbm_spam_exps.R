library(ElemStatLearn)
library(gbm)
library(BatchJobs)
source("gbm_spam_defs.R")


set.seed(1)
data = spam
data$spam = as.numeric(data$spam) - 1
n = nrow(data)

train.inds = sample(1:n, (2/3 * n))
train = data[train.inds, ]
test = data[-train.inds, ]


waitTillDone = function(reg) {
  submitJobs(reg)
  while(length(findMissingResults(reg)) > 0) {
    messagef("%i %i", length(findDone(reg)), length(findErrors(reg)))
    Sys.sleep(30)
  }
}

if (TRUE) {
  #unlink("gbm_spam-files", recursive = TRUE)
  #reg = makeRegistry("gbm_spam", packages="gbm")
  #batchExpandGrid(reg, getModel, 
  #  inter = inters, shrinkage = shrinks, 
  #  more.args = list(train = train, n.trees = n.trees)
  #)

  #waitTillDone(reg)
  reg = loadRegistry("gbm_spam-files")
  models = loadResults(reg)
  grid = reduceResultsDataFrame(reg, fun = function(job, res)
    list(inter=job$pars$inter, shrinkage=job$pars$shrinkage))
}

if (TRUE) {
  #unlink("gbm_spam_2-files", recursive = TRUE)
  #reg2 = makeRegistry("gbm_spam_2", packages="gbm")
  
  #batchMap(reg2, fun = function(model, test) {
  #  source("gbm_spam_defs.R")
  #  sapply(pred.n.trees, getErr, model = model, test = test)
  #}, model=models, more.args = list(test = test))

  #waitTillDone(reg2)
  reg2 = loadRegistry("gbm_spam_2-files")
  errs = loadResults(reg2)
}

