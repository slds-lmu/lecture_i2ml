#install.packages("mlr")
#http://mlr-org.github.io/mlr-tutorial/release/html/integrated_learners
library(mlr)
#load our dataset
library(AppliedPredictiveModeling)
data(abalone)
#http://archive.ics.uci.edu/ml/datasets/Abalone
#we only use 2 Features
data <- abalone[,c("LongestShell", "WholeWeight","Rings")]


library(ggplot2)
ggplot(data,aes(x=LongestShell,y=WholeWeight,color=Rings)) +
  geom_point(size=2) 


abalone.task <- makeRegrTask(data = data, target = "Rings")

n = getTaskSize(abalone.task)
train.set = setdiff(1:n,seq(3, n, by = 3))
test.set = seq(3, n, by = 3)
lrn.lm <- makeLearner("regr.lm")
mod.lm = train(lrn.lm, abalone.task, subset = train.set)
task.pred.lm = predict(mod.lm, task = abalone.task, subset = test.set)
task.pred.lm
performance(task.pred.lm)

plotLearnerPrediction(lrn.lm, task = abalone.task, features = c("LongestShell", "WholeWeight"), cv = 0)

lrn.kknn <- makeLearner("regr.kknn")
mod.kknn = train(lrn.kknn, abalone.task, subset = train.set)
task.pred.kknn = predict(mod.kknn, task = abalone.task, subset = test.set)
task.pred.kknn

plotLearnerPrediction(lrn.kknn, task = abalone.task, features = c("LongestShell", "WholeWeight"), cv = 0)
performance(task.pred.kknn)
#listMeasures("regr")

