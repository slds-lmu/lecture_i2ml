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
rF = makeLearner("classif.randomForest", par.vals = list(ntree = 50))
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
pdf("04-random-forest/figure_man/bm_stable_vs_unstable.pdf", w = 8, h = 5.8)
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
#       task.id    learner.id mmce.test.mean mmce.test.mean.bagged decrease
# 1       Glass classif.rpart          0.303                0.2797     7.58
# 6  Ionosphere classif.rpart          0.131                0.0883    32.59
# 11      Sonar classif.rpart          0.264                0.2164    18.03
# 16   Waveform classif.rpart          0.430                0.3500    18.60
# 3       Glass  classif.kknn          0.290                0.2708     6.64
# 8  Ionosphere  classif.kknn          0.160                0.1510     5.32
# 13      Sonar  classif.kknn          0.150                0.1540    -3.03
# 18   Waveform  classif.kknn          0.320                0.3200     0.00