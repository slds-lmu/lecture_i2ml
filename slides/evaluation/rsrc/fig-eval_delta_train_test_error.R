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
data <- mlbench::mlbench.2dnormals(n = 100000L, cl = 2L, r = sqrt(2L), sd = 2L)
data_dt <- data.table::as.data.table(data)

# Set aside large test dataset

set.seed(2L)
idx_test <- sample(data_dt[, .I], size = 0.9 * nrow(data_dt))
data_test <- data_dt[idx_test]
data_train <- data_dt[setdiff(data_dt[, .I], idx_test)]

# TRAINING ---------------------------------------------------------------------

# Define portions of training data to be used

train_sizes <- c(seq(5L, 50L, by = 5L), seq(100L, 10000L, by = 50L))
# train_sizes <- c(5L, 50L, 100L, 10000L)

# Define learner

learner <- mlr3::lrn("classif.svm", kernel = "radial", gamma = 0.001)

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

# p_1 <- ggplot2::ggplot(
#   data_dt, ggplot2::aes(x = x.1, y = x.2, col = classes)) +
#   ggplot2::geom_jitter(size = 0.8) +
#   ggplot2::theme_minimal() +
#   ggplot2::scale_color_viridis_d(end = 0.9) +
#   ggplot2::xlab(expr(x[1])) +
#   ggplot2::ylab(expr(x[2])) +
#   ggplot2::guides(color = FALSE)

# ggplot2::ggsave(
#   "../figure/eval_delta_train_test_err_data.pdf", 
#   p_1, 
#   height = 2L,
#   width = 3.5)

p_2 <- ggplot2::ggplot(
  results_dt, 
  ggplot2::aes(x = train_size, ymax = delta, ymin = 0)) +
  ggplot2::geom_linerange() +
  ggplot2::theme_minimal() +
  ggplot2::xlab("training set size") +
  ggplot2::ylab("test error - train error")

# ggplot2::ggsave(
#   "../figure/eval_delta_train_test_err.pdf", 
#   p_2, 
#   height = 2L,
#   width = 8L)
