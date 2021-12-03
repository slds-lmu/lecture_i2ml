library(mlr3verse)
library(mlbench)
library(stats)
library(mlr3measures)
library(dplyr)
library(stringr)

set.seed(0)

max_n <- 500
max_d <- 500
sample_sizes <- seq(from = 50, to = max_n, by = 50)
dims <- seq(from = 50, to = max_d, by = 50)
combos <- expand.grid(sample=sample_sizes, dim=dims)

make_task_data <- function(d=500, n=500) {
  peak <- mlbench.peak(d, n)
  data <- as.data.frame(peak$x)
  data$y <- peak$y
  task <- as_task_regr(data, target = "y", id = paste0(d, "_", n))
  task
}

tasks <- mapply(make_task_data, combos$dim, combos$sample)

df <- data.frame(learner_id=character(),
                 sample=integer(),
                 dim=integer(),
                 train_error=double(),
                 test_error=double(),
                 of=double())
measure <- msr("regr.mse")

for (i in 1:length(tasks)) {
  print(paste0("starting task ", i, "/", length(tasks)))
  task <- tasks[[i]]
  holdout <- rsmp("holdout", ratio=0.7)
  holdout$instantiate(task)
  y_train <- as.data.table(task)[holdout$train_set(1)][["y"]]
  y_test <- as.data.table(task)[holdout$test_set(1)][["y"]]
  learners <- list(
    lrn("regr.rpart", id="regression tree"),
    lrn("regr.ranger", id="random forest"),
    lrn("regr.svm", id="support vector machine")
  )
  for (learner in learners) {
    learner$train(task, row_ids=holdout$train_set(1))
    train_error <- learner$predict(task, row_ids=holdout$train_set(1))$score(measures=measure)[[1]]
    test_error <- learner$predict(task, row_ids=holdout$test_set(1))$score(measures=measure)[[1]]
    of <- test_error - train_error
    df <- rbind(df, list(learner_id=learner$id,
                         sample=dim(task$data())[1],
                         dim=dim(task$data())[2] - 1,
                         train_mse=train_error,
                         test_error=test_error,
                         of=of))
  }
  print(paste0("finished task ", i, "/", length(tasks)))
}

saveRDS(df, file = "datasets/overfitting.rds")



