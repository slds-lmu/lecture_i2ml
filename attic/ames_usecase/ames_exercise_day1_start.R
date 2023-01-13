# load packages
library(mlr3)
library(mlr3learners)

# load the data
train_set = read.csv("data/ames_housing_train.csv")

# the task
task = TaskRegr$new(id = "ames_housing", backend = train_set, target = "SalePrice")

# create a learner
learner = lrn("regr.featureless")

# train the learner
# EXCHANGE THIS PART WITH A PROPER BENCHMARK ANALYSIS!
learner$train(task)

# predict on new data
# CHOOSE THE BEST PERFOMING LEARNER OF YOUR BENCHMARK TO PREDICT ON NEW DATA!
test_set = read.csv("data/ames_housing_test.csv")
pred = learner$predict_newdata(task, test_set)

# we can save the predictions as data.table and export them for Kaggle
pred = as.data.table(pred)
pred$truth = NULL
write.csv(pred, "data/ames_housing_submission_start.csv", row.names = FALSE)
