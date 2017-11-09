library(mlr)
library(checkmate)
library(ggplot2)
set.seed(899)

# Benchmark experiment
# Reference: Breiman (1996). Bagging Predictors. Machine Learning, 24, 123-140.
# Note: Breiman's approach is more complex than this benchmark here
# Create learners and its respective bagged version
rpart.lrn = makeLearner("classif.rpart")
rpart.lrn.bagged = makeBaggingWrapper(rpart.lrn, bw.iters = 50)
kn = makeLearner("classif.kknn")
bagged.kn = makeBaggingWrapper(kn, bw.iters = 50)
randomForest = makeLearner("classif.randomForest", par.vals = list(ntree = 50))
lrns = list(rpart.lrn, rpart.lrn.bagged, kn, bagged.kn, rF)

# Get some tasks also used by Breiman 1996 and modify them when necessary
# some tasks which Breimna used contain missings and need to much preprocessing
# --> only those are used that are easy to implement
waveform.task = convertMLBenchObjToTask("mlbench.waveform")
waveform.task$task.desc$id <- "Waveform"
ionosphere.task = convertMLBenchObjToTask("Ionosphere")
ion.data = getTaskData(ionosphere.task)[,-2]
ionosphere.task = makeClassifTask("Ionosphere",
  data = ion.data, target = getTaskTargetNames(ionosphere.task))
glass.task = convertMLBenchObjToTask("Glass")
sonar.task$task.desc$id <- "Sonar"
tasks = list(waveform.task, ionosphere.task, glass.task,
  sonar.task)

# specify resampling procedure
rdesc = makeResampleDesc("CV", iters = 10)

# benchmark experiment
bmr = benchmark(lrns, tasks, rdesc)

# plot the aggregated results
jpeg("bm_stable_vs_unstable.jpg")
plotBMRBoxplots(bmr) + facet_wrap(~ task.id, scales = "free")
dev.off()

# EXTRA: overview table to get some numbers and an impression of the performance
# increase by bagging
perf = getBMRAggrPerformances(bmr, as.df = 2)
sub1 = subset(perf, learner.id == "classif.rpart")
sub2 = subset(perf, learner.id == "classif.rpart.bagged")[, 3, drop = FALSE]
colnames(sub2) = "mmce.test.mean.bagged"
sub3 = subset(perf, learner.id == "classif.kknn")
sub4 = subset(perf, learner.id == "classif.kknn.bagged")[, 3, drop = FALSE]
colnames(sub4) = "mmce.test.mean.bagged"
sub5 = subset(perf, learner.id == "classif.randomForest")[,3, drop = FALSE]
overview = rbind(cbind(sub1, sub2), cbind(sub3, sub4))
overview$decrease = ((overview$mmce.test.mean - overview$mmce.test.mean.bagged) / overview$mmce.test.mean) * 100
overview
