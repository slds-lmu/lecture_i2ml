library(mlbench)
library(mlr)

set.seed(123L)

spiral = mlbench.spirals(n = 500, sd = 0.1)
df_spiral = as.data.frame(spiral)

plot(spiral)

task = makeClassifTask(data = df_spiral, target = "classes")

plotLearnerPrediction("classif.lda", task)
plotLearnerPrediction("classif.qda", task)
plotLearnerPrediction("classif.logreg", task)
plotLearnerPrediction("classif.kknn", task, k = 5)
plotLearnerPrediction("classif.kknn", task, k = 1)
plotLearnerPrediction("classif.kknn", task, k = 100)
