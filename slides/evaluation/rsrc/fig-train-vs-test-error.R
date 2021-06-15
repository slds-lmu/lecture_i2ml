# ------------------------------------------------------------------------------
# Test vs Train Error
# ------------------------------------------------------------------------------

# PREREQ -----------------------------------------------------------------------


library(mlr3)
library(mlr3learners)
library(ggplot2)

# DATA -------------------------------------------------------------------------
set.seed(123L)

sd_spirals = 10
n = 100L
#spirals dataset
spirals_generator = tgen("spirals", sd = sd_spirals)
# get spirals data 
task = spirals_generator$generate(n = n) 

complexity_k = seq(1,10)
train_sizes = seq(0.1, 1, length.out = 15)
test_sizes = seq(0.1, 1, length.out = 15)

# EXPERIMENT -------------------------------------------------------------------



#list of different learners with increasing complexity 
learners_complexity = lapply(
  complexity_k,
  function(i) mlr3::lrn("classif.kknn", k = i))

learner = learners_complexity[[10]]

#split 
train_set = sample(task$nrow, 0.66 * task$nrow)
test_set = setdiff(seq_len(task$nrow), train_set)

train_sets = lapply(
  train_sizes,
  function(i) sample(length(train_set), i * length(train_set)))

test_sets = lapply(
  test_sizes,
  function(i) sample(length(test_set), i * length(test_set)))


#-------------------------------------------------------------------------------
# Varing Trainsize

length = 2*length(train_sets)

data = data.frame(error = numeric(length),
                  type = character(length),
                  train_size = numeric(length))

for(i in seq_along(train_sets)) {

    learner$train(task, row_ids = train_sets[[i]])
    
    #calculate training error
    pred_train = learner$predict(task, row_ids = train_sets[[i]])
    train_err = pred_train$score()
    
    #calculate test error
    pred_test = learner$predict(task, row_ids = test_set)
    test_err = pred_test$score()
    
    #fill data frame 
    data$train_size[i] = train_sizes[[i]]*length(train_set)
    data$error[i] = train_err
    data$type[i] = "train error"
    
    data$train_size[length/2+i] = train_sizes[[i]]*length(train_set)
    data$error[length/2+i] = test_err
    data$type[length/2+i] = "test error"
}



p1 = ggplot(data= data, aes(x = train_size, y= error, color= type)) +
  geom_line() +
  theme_minimal() +
  scale_color_viridis_d(end = 0.9) +
  xlab("Size of Trainigset") +
  ylab("Error")
            
p1




#-------------------------------------------------------------------------------











# re-fit the model
learner$train(task, row_ids = train_set)

# rebuild prediction object
pred_train = learner$predict(task, row_ids = train_set)
error_train = pred_train$score()

pred_test = learner$predict(task, row_ids = test_set)
error_test = pred_test$score()





p_1 = ggplot2::ggplot(
  data_dt[sample(data_dt[, .I], 0.5 * nrow(data_dt))], 
  ggplot2::aes(x = x.1, y = x.2, col = classes)) +
  ggplot2::geom_jitter(size = 0.1) +
  ggplot2::theme_minimal() +
  ggplot2::scale_color_viridis_d(end = 0.9) +
  ggplot2::xlab(expr(x[1])) +
  ggplot2::ylab(expr(x[2])) +
  ggplot2::guides(color = FALSE)



# Purpose: visualize 

library(data.table)
library(ggplot2)
library(mlr3)
library(mlr3learners)
library(mlbench)

# DATA -------------------------------------------------------------------------

# Simulate Gaussian mixture

set.seed(1L)
data = mlbench::mlbench.2dnormals(n = 100000L, cl = 2L, r = sqrt(2L), sd = 1L)
data_dt = data.table::as.data.table(data)

# Set aside large test dataset

set.seed(2L)
idx_test = sample(data_dt[, .I], size = 0.9 * nrow(data_dt))
data_test = data_dt[idx_test]
data_train = data_dt[setdiff(data_dt[, .I], idx_test)]

# TRAINING ---------------------------------------------------------------------

# Define portions of training data to be used

train_sizes = c(seq(5L, 50L, by = 5L), seq(100L, 10000L, by = 50L))

# Define learner

learner = mlr3::lrn("classif.rpart")

# Train and evaluate for each training set size

results = lapply(
  
  train_sizes,
  
  function(i) {
    
    # Define task
    
    set.seed(1L)
    
    task = mlr3::TaskClassif$new(
      "gauss2d", 
      backend = data_train[
        sample(data_train[, .I], size = i)], 
      target = "classes")
    
    # Train learner and compute training error
    
    learner$train(task)
    pred_train = learner$predict(task)
    error_train = pred_train$score()
    
    # Compute test error
    
    pred_test = learner$predict_newdata(data_test)
    error_test = pred_test$score()
    
    # Return
    
    list(
      train_size = i,
      error_train = error_train, 
      error_test = error_test,
      delta = error_test - error_train)
    
  }
)

results_dt = data.table::as.data.table(do.call(rbind, results))
for (i in names(results_dt)) results_dt[[i]] = unlist(results_dt[[i]])

# PLOTS ------------------------------------------------------------------------

p_1 = ggplot2::ggplot(
  data_dt, ggplot2::aes(x = x.1, y = x.2, col = classes)) +
  ggplot2::geom_jitter(size = 0.8) +
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

p_2 = ggplot2::ggplot(
  results_dt, 
  ggplot2::aes(x = train_size, ymax = delta, ymin = 0)) +
  ggplot2::geom_linerange() +
  ggplot2::theme_minimal() +
  ggplot2::xlab("training set size") +
  ggplot2::ylab("test error - train error")

ggplot2::ggsave(
  "../figure/eval_delta_train_test_err.pdf", 
  p_2, 
  height = 2L,
  width = 8L)
