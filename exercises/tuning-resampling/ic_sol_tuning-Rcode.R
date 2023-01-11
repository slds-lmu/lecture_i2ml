library(mlr3)
library(mlr3learners)

set.seed(123)

task = tsk("boston_housing")
nrow_task <- (task$backend$nrow)
lrn_knn = lrn("regr.kknn")

# Define search space
search_space <- seq(1:100)

# Define stopping criterion
max_evals <- 80

# Draw randomly from search space (= random search)
ks <- sample(search_space, max_evals, replace = F)


do_CV <- function(folds, k){
  data_indcs <- c(1:nrow_task)
  # start index of test set
  start_index <- 1
  # nmb. of elements per fold
  interval_length <- round(nrow_task/folds, 0)
  # vector to hold MSEs
  mse_vector <- c(1:folds)
  # CV iterations
  for (i in seq(folds)) {
    # define test indices
    test_indcs <- data_indcs[start_index:(start_index+interval_length-1)]
    # define train indices
    train_indcs <- setdiff(data_indcs, test_indcs)
    # set parameter according to tuning step we are in
    lrn_knn$param_set$values <- list(k = k)
    lrn_knn$train(task, train_indcs)
    predictions <- lrn_knn$predict(task, test_indcs)
    # calculate MSE for this CV-iteration
    mse_vector[i] <- mean((predictions$truth - predictions$response)^2)
    # update index
    start_index <- start_index + interval_length
  }
  # calculate avg. mse estimate
  return(mean(mse_vector))
}


# set initial value for list of optimal k with corresponding GE estimate
ge_est_iteration <- do_CV(folds = 5, k = 1)
ge_est_list <- list(k = 1, ge_est = ge_est_iteration)

# Tuning procedure:
# for each k
for (k in ks) {
  # calculate MSE via 5-fold CV and with given k
  ge_est_iteration <- do_CV(5, k)
  # if performance is better -> save k and estimate
  if (ge_est_iteration < ge_est_list[["ge_est"]]){
    ge_est_list[["k"]] <- k
    ge_est_list[["ge_est"]] <- ge_est_iteration
  }
}

# list of optimal k with corresponding GE estimate
ge_est_list
