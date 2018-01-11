
library(mlbench)
library(mlr)

set.seed(123L)

mydata1 = mlbench.spirals(n = 500, sd = 0.1)
mydata2 = as.data.frame(mydata1)

# head(mydata2)
# plot(mydata1)

task = makeClassifTask(data = mydata2, target = "classes")

lrn = makeLearner("classif.kknn")

myplot = function(learner, par.vals) {
  for (j in seq_row(par.vals)) {
    learner = setHyperPars(learner, par.vals = as.list(par.vals[j, , drop = FALSE]))
    pl = plotLearnerPrediction(learner, task)
    print(pl)
    pause()
  }
}


plotLearnerPrediction("classif.lda", task)
plotLearnerPrediction("classif.qda", task)
plotLearnerPrediction("classif.rpart", task)

myplot(
  learner = makeLearner("classif.kknn"),
  par.vals = data.frame(k = c(1, 5, 50, 450))
)


