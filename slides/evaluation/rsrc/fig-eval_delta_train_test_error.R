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

# Simulate Gaussian mixture

set.seed(1L)
data <- mlbench::mlbench.2dnormals(n = 100000L, cl = 2L, r = sqrt(2L), sd = 1L)
# data <- mlbench::mlbench.spirals(n = 10000L, sd = 0.1, cycles = 2L)
data_dt <- data.table::as.data.table(data)

# Set aside large test dataset

set.seed(2L)
idx_test <- sample(data_dt[, .I], size = 0.9 * nrow(data_dt))
data_test <- data_dt[idx_test]
data_train <- data_dt[setdiff(data_dt[, .I], idx_test)]

# TRAINING ---------------------------------------------------------------------

# Define portions of training data to be used

# train_sizes <- c(0.001, 0.005, 0.01, 0.05, 0.1, 0.25, 0.5, 0.75, 1)
train_sizes <- c(seq(5L, 50L, by = 5L), seq(100L, 10000L, by = 50L))

# Define learner

learner <- mlr3::lrn("classif.rpart")

# Train and evaluate for each training set size

results <- lapply(
  
  train_sizes,
  
  function(i) {
    
    # Define task
    
    set.seed(1L)
    
    task <- mlr3::TaskClassif$new(
      "gauss2d", 
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
      delta = error_test - error_train)
    
  }
)

results_dt <- data.table::as.data.table(do.call(rbind, results))
for (i in names(results_dt)) results_dt[[i]] <- unlist(results_dt[[i]])

# PLOTS ------------------------------------------------------------------------

p <- ggplot2::ggplot(
  results_dt, 
  ggplot2::aes(x = train_size, ymax = delta, ymin = 0)) +
  ggplot2::geom_linerange() +
  ggplot2::theme_minimal() +
  ggplot2::xlab("training set size") +
  ggplot2::ylab("test error - train error")
