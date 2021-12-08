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

make_regression_data <- function(d=500, n=500) {
  actual_n <- n + n_test

  X <- matrix(rnorm(d*(actual_n)), ncol = d)
  X <- cbind(matrix(1, nrow = actual_n), scale(X))

  beta <- matrix(0, nrow = d + 1)
  beta[1,] <- 5
  beta[2:d%/%2,] <- 3
  beta[(d%/%2+1):d,] <- -3

  y <- X%*%beta + rnorm(actual_n)

  list(X=X,y=y)
}

make_task_data <- function(d=500, n=500) {
  peak <- mlbench.peak(n=n + n_test,d=d)
  # reg <- make_regression_data(d=d,n=n)
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
  lrn("regr.lm", id="Linear Model"),
  lrn("regr.rpart", id="Regression Tree"),
  lrn("regr.kknn", id="K-Nearest Neighbors"),
  lrn("regr.ranger", id="Random Forest"),
  lrn("regr.xgboost", id="Gradient Boosting", nthread=4, nrounds=10),
  lrn("regr.svm", id="Support Vector Machine")
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

# saveRDS(df, file = "overfiting_mlr.rds")

saveRDS(df, file = "overfitting_peak_boost_10rounds.rds")

options(warn = defaultW)



