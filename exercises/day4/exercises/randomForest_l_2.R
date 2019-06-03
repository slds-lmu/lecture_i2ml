library(mlr)
library(mlbench)

set.seed(123)
data = mlbench.spirals(500, sd = 0.1)
data = as.data.frame(data)
task = makeClassifTask(data = data, target = "classes")


mds = 1:5

for (md in mds) {
  print(plotLearnerPrediction("classif.rpart", task, maxdepth = md))
  BBmisc::pause()
}

ntrees = c(1, 10, 20, 100, 1000)

for (nt in ntrees) {
  print(plotLearnerPrediction("classif.randomForest", task, ntree = nt))
  BBmisc::pause()
}
