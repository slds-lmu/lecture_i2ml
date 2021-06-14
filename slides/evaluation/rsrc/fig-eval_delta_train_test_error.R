# ------------------------------------------------------------------------------
# FIG: DELTA TRAIN-TEST ERROR
# ------------------------------------------------------------------------------

# Purpose: visualize how delta between train and test error vanishes for 
# increasing amount of training observations

library(data.table)
library(ggplot2)
library(mlr3)
library(mlr3learners)
library(mlbench)

# DATA -------------------------------------------------------------------------

# Simulate spirals data

set.seed(1L)
data <- mlbench::mlbench.spirals(n = 100000L, cycles = 2L, sd = 0.3)
data_dt <- data.table::as.data.table(data)

# Set aside large test data set

set.seed(2L)
idx_test <- sample(data_dt[, .I], size = 0.9 * nrow(data_dt))
data_test <- data_dt[idx_test]
data_train <- data_dt[setdiff(data_dt[, .I], idx_test)]

# Reduce amount of data for contradictory example

set.seed(3L)
idx_small <- sample(data_dt[, .I], size = 0.05 * nrow(data_dt))
data_small <- data_dt[idx_small]

set.seed(4L)
idx_small_test <- sample(data_small[, .I], size = 0.3 * nrow(data_small))
data_small_test <- data_small[idx_small_test]
data_small_train <- data_small[setdiff(data_small[, .I], idx_small_test)]

# TRAINING ---------------------------------------------------------------------

# Define portions of training data to be used

train_sizes <- c(seq(5L, 50L, by = 5L), seq(100L, 10000L, by = 50L))

# Define learner

learner <- mlr3::lrn("classif.ranger", max.depth = 5L, num.trees = 100L)

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
  backend = data_small_train, 
  target = "classes")

tree_depths <- c(1L:4L, seq(5L, 30L, by = 5L), 50L)

learners <- lapply(
  tree_depths,
  function(i) mlr3::lrn("classif.ranger", max.depth = i, num.trees = 100L))

invisible(lapply(learners, function(i) i$train(task_small)))

preds_train <- lapply(learners, function(i) i$predict(task_small)) 
errors_train <- sapply(preds_train, function(i) i$score())

errors_test <- sapply(
  learners, 
  function(i) i$predict_newdata(data_small_test)$score())

results_complexity <- data.table::data.table(
  tree_depths,
  errors_train,
  errors_test)

results_complexity <- data.table::melt(
  results_complexity,
  id = "tree_depths", 
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
  ggplot2::aes(x = tree_depths, y = value, col = variable)) +
  ggplot2::geom_line() +
  ggplot2::theme_minimal() +
  ggplot2::scale_color_viridis_d(
    name = "error",
    labels = c("train", "test"),
    end = 0.85) +
  ggplot2::xlab("maximum tree depth") +
  ggplot2::ylab("MCE")

ggplot2::ggsave(
  "../figure/eval_delta_train_test_overfit.pdf",
  p_3,
  height = 2L,
  width = 4.5)
