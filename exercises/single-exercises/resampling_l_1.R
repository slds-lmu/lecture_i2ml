library(mlr)
library(mlbench)

#Example: multi.class classification
data(Satellite)
summary(Satellite)
Satellite.task = makeClassifTask(data = Satellite, target = "classes")
knn.learner = makeLearner("classif.kknn", k = 3)
# As performance measure we will be using the kappa coefficient, which measures
# the agreement between to scores.

# Train and test subsets:
set.seed(42)
train_indices = sample.int(nrow(Satellite), size = 0.8 * nrow(Satellite))
test_indices = setdiff(1:nrow(Satellite), train_indices)

# a)
mod = train(knn.learner, task = Satellite.task, subset = train_indices)
pred = predict(mod, task = Satellite.task, subset = train_indices)
perf.train = performance(pred, measure = mlr::kappa)
perf.train

# b)
pred = predict(mod, task = Satellite.task, subset = test_indices)
perf.test = performance(pred, measure = mlr::kappa)
perf.test

# c)
rdesc = makeResampleDesc(method = "CV", iters = 10)
listMeasures("classif")
res = resample(knn.learner, Satellite.task, rdesc, measures = list(mlr::kappa))
res

# d)
# - Training performance is too optimistic, because the kappa is much higher than on new
#   test data
# - Test performance is unbiased, but it depends on the split, as can be seen in the CV folds:
#   Each CV fold represents a training test split and the kappa measure varies between folds.
# - The CV estimate averages over the different splits and gives an unbiased, more robust estimate.
# - The CV estimate is preferable over the other two, but more computationally expensive
