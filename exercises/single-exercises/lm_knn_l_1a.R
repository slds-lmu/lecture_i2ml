library(mlr)

# http://archive.ics.uci.edu/ml/datasets/Abalone
# we only use 2 Features

abalone = read.csv("exercises/data/abalone.csv", header = FALSE)
colnames(abalone) = c("Sex", "LongestShell", "Diameter", "Height", "WholeWeight", "ShuckedWeight", "VisceraWeight", "ShellWeight", "Rings")
data = abalone[, c("LongestShell", "WholeWeight","Rings")]


# a)
library(ggplot2)
ggplot(data,aes(x = LongestShell, y = WholeWeight, color = Rings)) +
  geom_point(size = 2)

# Preparation for b) and c)
abalone.task = makeRegrTask(data = data, target = "Rings")

# b)
lrn.lm = makeLearner("regr.lm")
mod.lm = train(lrn.lm, abalone.task)
task.pred.lm = predict(mod.lm, task = abalone.task)
task.pred.lm


# c)
lrn.kknn = makeLearner("regr.kknn", k = 5)
mod.kknn = train(lrn.kknn, abalone.task)
task.pred.kknn = predict(mod.kknn, task = abalone.task)
task.pred.kknn

# d)
plotLearnerPrediction(lrn.lm, task = abalone.task, features = c("LongestShell", "WholeWeight"), cv = 0)
plotLearnerPrediction(lrn.kknn, task = abalone.task, features = c("LongestShell", "WholeWeight"), cv = 0)
