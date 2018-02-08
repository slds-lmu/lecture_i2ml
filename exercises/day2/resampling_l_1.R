library(mlr)
library(mlbench)

#Example:
data(Satellite)
summary(Satellite)
Satellite.task = makeClassifTask(data = Satellite, target = "classes")
knn.learner = makeLearner("classif.kknn")

#choose k
k=10
rdesc = makeResampleDesc(method = "CV", iters = k)
listMeasures("classif")
res = resample(knn.learner, Satellite.task, rdesc, measures = list(mlr::kappa))
res

