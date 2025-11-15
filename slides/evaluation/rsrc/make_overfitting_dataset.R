library(mlr3verse)
library(mlbench)
library(stats)
library(mlr3measures)
library(dplyr)
library(stringr)

defaultW <- getOption("warn")
options(warn = -1)

set.seed(0)

min_n <- 100
min_d <- 10
max_n <- 5000
max_d <- 500
len_n <- 10
len_d <- 10
sample_sizes <- ceiling(2^seq(log2(min_n), log2(max_n), length = len_n))
dims <- ceiling(2^seq(log2(min_d), log2(max_d), length = len_d))

n_test <- 10000
n_iters <- 10

make_task_data <- function(d=500, n=500) {
  peak <- mlbench.peak(n=n + n_test,d=d)
  data <- as.data.frame(peak$x)
  data$y <- peak$y
  task <- as_task_regr(data, target = "y", id = paste0(d, "_", n))
  task
}

df <- data.frame(learner_id=character(),
                 sample=integer(),
                 dim=integer(),
                 train_error=double(),
                 test_error=double(),
                 of=double())
measure <- msr("regr.mse")

learners <- list(
  lrn("regr.svm", id="SVM (gamma=1/p)", cost=1, kernel="radial", type="eps-regression"),
  lrn("regr.ranger", id="Random Forest", num.trees=500, num.threads=4),
  lrn("regr.xgboost", id="Gradient Boosting", nthread=4, nrounds=100),
  lrn("regr.rpart", id="Regression Tree", maxdepth=30, minsplit=20),
  lrn("regr.svm", id="SVM (gamma=1)", gamma=1, cost=1, kernel="radial", type="eps-regression"),
  lrn("regr.kknn", id="K-Nearest Neighbors", k=7, distance=2)
)

for (i in 1:length(dims)) {
  for (j in 1:length(sample_sizes)) {
    d <- dims[i]
    n <- sample_sizes[j]
    print(paste0("starting task w/ dim=", d, " & sample_size=", n))
    of_list <- list()
    train_error_list <- list()
    test_error_list <- list()
    for (iter in 1:n_iters) {
      task <- make_task_data(d=d,n=n)
      holdout <- rsmp("holdout", ratio=as.double(n)/(n_test + n))
      holdout$instantiate(task)
      for (learner in learners) {
        learner$train(task, row_ids=holdout$train_set(1))
        train_error <- learner$predict(task, row_ids=holdout$train_set(1))$score(measures=measure)[[1]]
        test_error <- learner$predict(task, row_ids=holdout$test_set(1))$score(measures=measure)[[1]]
        of <- test_error - train_error
        if (learner$id %in% names(of_list)) {
          of_list[[learner$id]] <- of_list[[learner$id]] + of
          train_error_list[[learner$id]] <- train_error_list[[learner$id]] + train_error
          test_error_list[[learner$id]] <- test_error_list[[learner$id]] + test_error
        } else {
          of_list[[learner$id]] <- of
          train_error_list[[learner$id]] <- train_error
          test_error_list[[learner$id]] <- test_error
        }
        learner$reset()
      }
    }
    for (learner in learners) {
      df <- rbind(df, list(learner_id=learner$id,
                       sample=n,
                       dim=d,
                       of=of_list[[learner$id]]/n_iters,
                       train_error=train_error_list[[learner$id]]/n_iters,
                       test_error=test_error_list[[learner$id]]/n_iters
      ))
    }
    print(paste0("finished task w/ dim=", d, " & sample_size=", n))
  }

}

saveRDS(df, file = "overfitting_peak.rds")

options(warn = defaultW)



