# Spam-Example without mlr
library(ElemStatLearn)
library(gbm)
library(ggplot2)
library(gridExtra)

set.seed(1)
data = spam
data$spam = as.numeric(data$spam) - 1
n = nrow(data)

train.inds = sample(1:n, (2/3 * n))
train = data[train.inds, ]
test = data[-train.inds, ]

n.trees = 1800
#n.trees = 10000
#shrinks = c(0.1, 0.01)
shrinks = c(0.1, 0.01, 0.001)
#inters = c(1, 4, 7)
inters = seq(1, 16, 3)
pred.n.trees = seq(1, n.trees, length.out = 4)
#pred.n.trees = seq(1, n.trees, length.out = 30)

getModel = function(train, n.trees, inter, shrinkage) {
  gbm(spam ~ ., data = train,
      distribution = "bernoulli", train.fraction = 1,
      n.trees = n.trees, interaction.depth = inter,
      shrinkage = shrinkage
  )
}

getPred = function(model, test, n.trees) {
  pred = predict(model, newdata = test,
                 n.trees = n.trees, type = "response")
  pred = as.numeric(pred > 0.5)
}

getErr = function(model, test, n.trees) {
  pred = getPred(model, test, n.trees)
  mean(pred != test$spam)
}
getErrVector = Vectorize(getErr, vectorize.args = "n.trees")

######################
# manual grid search #
models.all = list()
n.comb = length(shrinks) * length(inters) * length(pred.n.trees)
error.df = data.frame(shrinkage = numeric(n.comb), max.tree.depth = integer(n.comb),
  M = integer(n.comb), err = numeric(n.comb))

# going through the parameter grid and saving test error for each combination:
{
  len.M = length(pred.n.trees)
  i = 1L
  print("Start fitting.")
  for (k in shrinks) {
    print(paste("shrinkage =", k))
    models.all[[toString(k)]] = list()
    for (j in inters) {
      print(Sys.time())
      print(paste("maximum tree depth =", j))
      fit.tmp = getModel(train, n.trees = n.trees, inter = j, shrinkage = k)
      print("Done fitting.")
      models.all[[toString(k)]][[toString(j)]] = fit.tmp
      err.tmp = getErrVector(fit.tmp, test, pred.n.trees)
      print("Done calculating error.")
      error.df[(1+(i-1)*len.M):(i*len.M), ] = cbind(rep(k, len.M), rep(j, len.M), pred.n.trees, err.tmp)
      i = i + 1L
    }
  }
  print(Sys.time())
}

error.df$max.tree.depth = as.factor(error.df$max.tree.depth)

save(error.df, file = "spam_example.RData")

#fit = getModel(data, n.trees = 20000, inter = 4, shrinkage = 0.1) # takes around 5 minutes on i5-
#fit.error.path = getErrVector(fit, test, 1:1380) # this takes forever

# select best observed model
error.df[which.min(error.df$err), ]
model = getModel(data, n.trees = 1627, inter = 4, shrinkage = 0.1)
model.error.path = getErrVector(model, test, 1:1627)

# test set error: 0.045
# NB: error estimator will be slightly biased!

summary(mod$learner.model, cBars = 10)
gbm.perf(mod$learner.model, method = "OOB")
plot.gbm(model, 52)
plot.gbm(model, 25)


# is there subsampling?
set.seed(1)
fit.test1 = getModel(data, n.trees = 3, inter = 4, shrinkage = 0.1)
#set.seed(1)
fit.test2 = getModel(data, n.trees = 3, inter = 4, shrinkage = 0.1)
getErrVector(fit.test1, test, 1:3)
getErrVector(fit.test2, test, 1:3)
# yes; default is 0.5

####################################################################################################
# Spam example with mlr
library(mlr)

# for spam data set
library(ElemStatLearn)

task = makeClassifTask(data = spam, target = "spam")
lrn = makeLearner("classif.gbm")

ps = makeParamSet(
  makeDiscreteParam("shrinkage", values = c(0.1, 0.01, 0.001)),
  makeDiscreteParam("n.trees", floor(seq(1, 20000, length.out = 30))[1:4]),
  makeDiscreteParam("interaction.depth", seq(1, 16, 3)[1:3])
)

ctrl = makeTuneControlGrid()
rdesc = makeResampleDesc("CV", iters = 3L)

res = tuneParams(learner = lrn, task = task, resampling = rdesc,
  par.set = ps, control = ctrl)

lrn.tuned = makeLearner("classif.gbm", par.vals = res$x)

#
lrn.tuned = makeLearner("classif.gbm", shrinkage = 0.1, n.trees = 1380L, interaction.depth = 4L)
# select best observed model

mod = train(lrn.tuned, task)

summary(mod$learner.model, cBars = 10)
