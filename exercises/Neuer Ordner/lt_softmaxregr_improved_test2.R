set.seed(123)
source("lt_softmaxregr_improved.R")

df = iris
X = df[, 1:4]
Y = df[, 5]

ind = sample(nrow(df))
trind =  ind[1:100]
teind =  ind[101:150]
xtrain = as.matrix(X[trind, ])
xtrain = cbind(xtrain, 1)
ytrain = as.integer(Y[trind])
m1 = trainSoftmaxRegr1(xtrain, ytrain, step.size = "linesearch", maxit = 1000)
# softmax has the property of supressing overfitting?
print(m1)
m2 = trainSoftmaxRegr2(xtrain, ytrain)
print(m2)
xtest = as.matrix(X[teind, ])
xtest = cbind(xtest,1)
ytest = as.integer(Y[teind])
p1 = predictSoftmaxRegr(m1, xtest, ytest)
print(p1$err)
p2 = predictSoftmaxRegr(m2, xtest, ytest)
print(p2$err)

library(mlr)
set.seed(123)
iris.task
lrn = makeLearner("classif.multinom")
holdout(learner = lrn, task = iris.task, split = 2/3, measures = mmce)
