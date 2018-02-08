library(mlr)



##a)

data(bodyfat, package = "TH.data")
summary(bodyfat)
fat.task = makeRegrTask(data = bodyfat, target = "DEXfat")

##b)

knn.learner = makeLearner("regr.kknn")
# Set the hyperparameters of a learner object
# knn.learner = setHyperPars(knn.learner)

fat.knn.model = train(knn.learner, fat.task)
fat.knn.model


##c)

plotLearnerPrediction(knn.learner, fat.task, features = "waistcirc")
plotLearnerPrediction(knn.learner, fat.task, features = "anthro3c")
plotLearnerPrediction(knn.learner, fat.task, features = c("waistcirc", "anthro3c"))


##d)

rdesc = makeResampleDesc(method = "CV", iters = 10)
res = resample(knn.learner, fat.task, rdesc, measures = list(mlr::mse, medae))
res

