library(mlr3)
library(mlr3learners)
library(mlr3viz)

# Download data from:
# http://archive.ics.uci.edu/ml/datasets/Abalone

url <-
  "http://archive.ics.uci.edu/ml/machine-learning-databases/abalone/abalone.data"
abalone <- read.table(url, sep = ",", row.names = NULL)
colnames(abalone) <- c(
  "Sex", "LongestShell", "Diameter", "Height",
  "WholeWeight", "ShuckedWeight", "VisceraWeight",
  "ShellWeight", "Rings"
)

# We only use 2 features:
data <- abalone[, c("LongestShell", "WholeWeight", "Rings")]

# a)
library(ggplot2)
ggplot(data, aes(x = LongestShell, y = WholeWeight, color = Rings)) +
  geom_point(size = 2)

# Preparation for b) and c)
task_abalone <- TaskRegr$new(id = "abalone", backend = data, target = "Rings")

# b)

learner_lm <- lrn("regr.lm")
learner_lm$train(task_abalone)
pred_lm <- learner_lm$predict(task_abalone)

head(data.frame(
  id = 1:length(pred_lm$truth), truth = pred_lm$truth,
  response = pred_lm$response
))

# c)
learner_knn <- lrn("regr.kknn", k = 5)
learner_knn$train(task_abalone)
pred_knn <- learner_knn$predict(task_abalone)

head(data.frame(
  id = 1:length(pred_knn$truth), truth = pred_knn$truth,
  response = pred_knn$response
))

# d)
autoplot(pred_lm)
autoplot(pred_knn)