# ------------------------------------------------------------------------------
# FIG: DELTA TRAIN-TEST ERROR
# ------------------------------------------------------------------------------

# Purpose: visualize how delta between train and test error vanishes for 
# increasing amount of training observations

library(data.table)
library(ggplot2)
library(mlr3)
library(mlr3extralearners)
if (FALSE) mlr3extralearners::install_learners("classif.fnn")
library(mlbench)

# DATA -------------------------------------------------------------------------

# Simulate spirals data

set.seed(1L)
data <- mlbench::mlbench.spirals(n = 100000L, cycles = 2L, sd = 0.1)
data_dt <- data.table::as.data.table(data)

# Set aside large test data set

set.seed(2L)
idx_test <- sample(data_dt[, .I], size = 0.7 * nrow(data_dt))
data_test <- data_dt[idx_test]
data_train <- data_dt[setdiff(data_dt[, .I], idx_test)]

# Reduce amount of data for contradictory example

set.seed(3L)
idx_small <- sample(data_dt[, .I], size = 0.005 * nrow(data_dt))
data_small <- data_dt[idx_small]

# TRAINING ---------------------------------------------------------------------

# Define portions of training data to be used

train_sizes <- c(16L, seq(20L, 50L, by = 5L), seq(100L, 30000L, by = 200L))
# train_sizes <- c(21L, 50L, 10000L, 30000L)

# Define learner

learner <- mlr3::lrn("classif.fnn", k = 15L)

# Train and evaluate for each training set size

results <- lapply(
  
  train_sizes,
  
  function(i) {
    
    # Define task
    
    set.seed(1L)
    
    task <- mlr3::TaskClassif$new(
      "spirals", 
      backend = data_train[
        sample(data_train[, .I], size = i)], 
      target = "classes")
    
    # Train learner and compute training error
    
    learner$train(task)
    pred_train <- learner$predict(task)
    error_train <- pred_train$score()
    
    # Compute test error
    
    pred_test <- learner$predict_newdata(data_test)
    error_test <- pred_test$score()
    
    # Return
    
    list(
      train_size = i,
      error_train = error_train, 
      error_test = error_test,
      delta = abs(error_test - error_train))
    
  }
)

results_dt <- data.table::as.data.table(do.call(rbind, results))
for (i in names(results_dt)) results_dt[[i]] <- unlist(results_dt[[i]])

# Vary complexity to show how training error can become much less reliable

task_small <- mlr3::TaskClassif$new(
  "spirals_small", 
  backend = data_small, 
  target = "classes")

n_neighbors <- c(1L:5L, 10L, 15L, 20L, 25L)

learners <- lapply(
  n_neighbors,
  function(i) mlr3::lrn("classif.fnn", k = i))

invisible(lapply(learners, function(i) i$train(task_small)))

preds_train <- lapply(learners, function(i) i$predict(task_small)) 
errors_train <- sapply(preds_train, function(i) i$score())

errors_test <- sapply(
  learners, 
  function(i) i$predict_newdata(data_test)$score())

results_complexity <- data.table::data.table(
  n_neighbors,
  errors_train,
  errors_test)

results_complexity <- data.table::melt(
  results_complexity,
  id = "n_neighbors", 
  measure = c("errors_train", "errors_test"))

# PLOTS ------------------------------------------------------------------------

set.seed(3L)
p_1 <- ggplot2::ggplot(
  data_dt[sample(data_dt[, .I], 0.5 * nrow(data_dt))], 
  ggplot2::aes(x = x.1, y = x.2, col = classes)) +
  ggplot2::geom_jitter(size = 0.1) +
  ggplot2::theme_minimal() +
  ggplot2::scale_color_viridis_d(end = 0.9) +
  ggplot2::xlab(expr(x[1])) +
  ggplot2::ylab(expr(x[2])) +
  ggplot2::guides(color = FALSE)

ggplot2::ggsave(
  "../figure/eval_delta_train_test_err_data.pdf",
  p_1,
  height = 2L,
  width = 3.5)

p_2 <- ggplot2::ggplot(
  results_dt, 
  ggplot2::aes(x = train_size, ymax = delta, ymin = 0)) +
  ggplot2::geom_linerange() +
  ggplot2::theme_minimal() +
  ggplot2::scale_x_log10() +
  ggplot2::xlab("training set size (log scale)") +
  ggplot2::ylab("test error - train error") 

ggplot2::ggsave(
  "../figure/eval_delta_train_test_err.pdf",
  p_2,
  height = 2L,
  width = 8L)

p_3 <- ggplot2::ggplot(
  results_complexity,
  ggplot2::aes(x = n_neighbors, y = value, col = variable)) +
  ggplot2::geom_line() +
  ggplot2::theme_minimal() +
  ggplot2::scale_x_reverse() +
  ggplot2::scale_color_viridis_d(
    name = "error",
    labels = c("train", "test"),
    end = 0.85) +
  ggplot2::xlab("number of neighbors") +
  ggplot2::ylab("MCE")

ggplot2::ggsave(
  "../figure/eval_delta_train_test_overfit.pdf",
  p_3,
  height = 2L,
  width = 4.5)
