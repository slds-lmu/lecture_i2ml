
library(mlr)
library(mlbench)
library(ggplot2)
library(BBmisc)

data("BostonHousing", "mtcars", package = c("mlbench", "datasets"))
tasks = list(
  makeRegrTask(data = BostonHousing, target = "medv"),
  makeRegrTask(data = mtcars, target = "mpg")
)
learners = list(
  makeLearner("regr.rpart"),
  makeLearner("regr.randomForest")
)

set.seed(1)
bmr = benchmark(learners, tasks, resamplings = cv2, measures = mlr::mse)
res = reshape2::dcast(data =  getBMRPerformances(bmr, as.df = TRUE), formula = task.id + iter ~ learner.id)

colnames(res) = c("Dataset", "k-th fold", "MSE (rpart)", "MSE (randomForest)")
kable(res, align = "c")
############################################################################