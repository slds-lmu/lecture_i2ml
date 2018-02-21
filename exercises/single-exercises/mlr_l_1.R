library(mlr)



##a)

data(bodyfat, package = "TH.data")
summary(bodyfat)
fat.task = makeRegrTask(data = bodyfat, target = "DEXfat")

##b)

tree.learner = makeLearner("regr.rpart", cp = 0.05)
# Alternative:
tree.learner = makeLearner("regr.rpart")
tree.learner = setHyperPars(tree.learner, cp = 0.05)

fat.tree.model = train(tree.learner, fat.task)
fat.tree.model


##c)

plotLearnerPrediction(tree.learner, fat.task, features = "waistcirc")
plotLearnerPrediction(tree.learner, fat.task, features = "anthro3c")
plotLearnerPrediction(tree.learner, fat.task, features = c("waistcirc", "anthro3c"))


##d)

rdesc = makeResampleDesc(method = "CV", iters = 10)
res = resample(tree.learner, fat.task, rdesc, measures = list(mlr::mse, medae))
res
