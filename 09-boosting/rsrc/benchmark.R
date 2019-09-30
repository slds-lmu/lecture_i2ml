library(mlr)
library(OpenML)

lrns = list(
  makeLearner("classif.xgboost", nrounds = 100L, eta = 0.1, max_depth = 4),
  makeLearner("classif.gbm", n.trees = 100, shrinkage = 0.1, interaction.depth = 4),
  makeLearner("classif.ada", iter = 100, nu = 0.1, maxdepth = 4),
  makeLearner("classif.glmboost", mstop = 100, nu = 0.1),
  makeLearner("classif.h2o.gbm", ntrees = 100, learn_rate = 0.1, max_depth = 4),
  makeLearner("classif.randomForest", ntree = 100)
)


OML_TASK_IDS = c(3854, 31, 3, 37)

tasks = lapply(OML_TASK_IDS, function(x) createDummyFeatures(convertOMLTaskToMlr(getOMLTask(x))$mlr.task))



bmr = benchmark(lrns, tasks, cv10, list(acc, timetrain), keep.pred = FALSE, models = FALSE)
save(bmr, file = "benchmark.RData")
