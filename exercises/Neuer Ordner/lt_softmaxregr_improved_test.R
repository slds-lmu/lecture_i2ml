set.seed(123)

df = iris
df = df[sample(nrow(df)), ]
X = df[, 1:4]
Y = df[, 5]
x = as.matrix(X[1:100, ])
x = cbind(x, 1)
y = as.integer(Y[1:100])
m1 = trainSoftmaxRegr1(x, y, step.size = "linesearch", maxit = 400)
# softmax has the property of supressing overfitting?
print(m1)
m2 = trainSoftmaxRegr2(x, y)
print(m2)
xtest = as.matrix(X[101:150, ])
xtest = cbind(xtest,1)
ytest = as.integer(Y[101:150])
p1 = predictSoftmaxRegr(m1, xtest, ytest)
print(p1$err)
p2 = predictSoftmaxRegr(m2, x, y)
print(p2$err)
library(mlr)
iris.task
lrn = makeLearner("classif.multinom")
holdout(learner = lrn, task = iris.task, split = 2/3, measures = mmce)
