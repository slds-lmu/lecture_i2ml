# goal here is to visualize how a RF does not overfit 'harder' when ntrees is increased! 

library(mlr3)
library(mlr3learners)
library(mlr3pipelines)
library(mlr3tuning)
library(mlr3viz)
library(ggplot2)
library(data.table)

set.seed(123)

# to encourage overfitting, we specify the RF as:
learner_rf_regr = lrn("regr.ranger", 
                      num.trees = 1, # starting with one tree
                      max.depth = 0, # no depth limit
                      min.node.size = 1) # minimum node size of 1

# we use mtcars to (hopefully) overfit
task_regr = tsk("mtcars")

collect_mse <- function(max_trees) {
  results <- data.table(num_trees = integer(), mse_train = numeric(), mse_test = numeric())
  
  # this loops through all trees, so that each time training and testing error is computed 
  # and increases the number of trees in the forest each time by 1
  for (ntree in 1:max_trees) {
    learner_rf_regr$param_set$values$num.trees <- ntree
    
    resampling <- rsmp("holdout")
    resampling$instantiate(task_regr)
    
    # training the learner
    train_set <- resampling$train_set(1)
    learner_rf_regr$train(task_regr, row_ids = train_set)
    
    # predicting training data
    train_pred <- learner_rf_regr$predict(task_regr, row_ids = train_set)
    mse_train <- train_pred$score(msr("regr.mse"))
    
    # predicting testing data
    test_set <- resampling$test_set(1)
    test_pred <- learner_rf_regr$predict(task_regr, row_ids = test_set)
    mse_test <- test_pred$score(msr("regr.mse"))
    
    results <- rbind(results, data.table(num_trees = ntree, mse_train = mse_train, mse_test = mse_test))
  }
  
  return(results)
}

results <- collect_mse(100)

p <- ggplot(results, aes(x = num_trees)) +
     geom_line(aes(y = mse_train, color = "mse.train"), size = 4) +
     geom_line(aes(y = mse_test, color = "mse.test"), size = 4) +
     labs(x = "number of trees", y = "MSE for holdout splitting on mtcars", color = "error type") +
     theme_minimal(base_size = 30) +
     scale_color_manual(values = c("mse.train" = "green", "mse.test" = "orange"))

ggsave("../figure/forest-overfit.png", plot = p, width = 16, height = 8, dpi = 300)