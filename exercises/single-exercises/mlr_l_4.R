
library(mlbench)
library(mlr)

set.seed(123L)

mydata1 = mlbench.spirals(n = 500, sd = 0.1)
mydata2 = as.data.frame(mydata1)

# head(mydata2)
# plot(mydata1)

task = makeClassifTask(data = mydata2, target = "classes")

plotLearnerPrediction("classif.lda", task)
plotLearnerPrediction("classif.qda", task)
plotLearnerPrediction("classif.logreg", task)
plotLearnerPrediction("classif.kknn", task, k = 5)
plotLearnerPrediction("classif.kknn", task, k = 1)
plotLearnerPrediction("classif.kknn", task, k = 100)

