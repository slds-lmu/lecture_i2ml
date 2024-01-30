# ------------------------------------------------------------------------------
# TUNING k-NN
# ------------------------------------------------------------------------------

library(data.table)
library(mlr3)
library(mlr3learners)
library(ggplot2)

# DATA -------------------------------------------------------------------------

# Data adapted from 
# https://www.openml.org/search?type=data&sort=runs&status=active&qualities.NumberOfClasses=lte_1&id=41021

data_baseball <- fread("exercises/tuning/ex_rnw/baseball.csv")
data_baseball$team <- as.factor(data_baseball$team)
data_baseball$league <- as.factor(data_baseball$league)

# HELPER FUNCIONS --------------------------------------------------------------

# Cross-validation

resample_cv <- function(idx, folds, seed = 123) {
    
    # shuffle indices
    set.seed(seed)
    idx <- idx[sample(idx, length(idx))]
    
    # prepare objects needed to store indices
    start_index <- 1
    interval_length <- floor(length(idx) / folds)
    idx_list <- vector(mode = "list", length = folds)
    
    # CV iterations
    for (i in seq(folds)) {
        
        # define test and train indices
        test_idx <- idx[start_index : (start_index + interval_length - 1)]
        train_idx <- setdiff(idx, test_idx)
        
        idx_list[[i]]$test <- test_idx
        idx_list[[i]]$train <- train_idx
        
        start_index <- start_index + interval_length
        
    }
    
    # return
    idx_list
    
}

# Assert that resampling works as desired

folds <- 5
unique_pairs <- which(lower.tri(diag(folds)), arr.ind = TRUE)
idx_to_check <- resample_cv(1:100, 5)

for (i in seq_len(nrow(unique_pairs))) {
    print(
        intersect(
            idx_to_check[[unique_pairs[i, 1]]]$test,
            idx_to_check[[unique_pairs[i, 2]]]$test
        )
    )
}

# SET-UP -----------------------------------------------------------------------

# Define task and learner
task <- TaskRegr$new("bb", backend = data_baseball, target = "runs_scored")
lrn_knn = lrn("regr.kknn")

# Define tuning settings
search_space <- 1:100
max_evals <- 80
folds <- 5
resampling_idx <- resample_cv(task$row_ids, folds)

# TUNING PROCEDURE -------------------------------------------------------------

# Get configuration candidates
set.seed(123)
k_candidates <- sample(search_space, max_evals)

# Define object to store tuning evaluations
tuning_archive <- data.table(
    "iteration" = seq_along(k_candidates), "k" = k_candidates, "ge" = 0
)

for (i in tuning_archive$iteration) {
    
    # Set current configuration
    lrn_knn$param_set$values <- list(k = tuning_archive[iteration == i, k])
    
    # Estimate GE via 5-CV
    ge_est <- 0
    for (j in folds) {
        lrn_knn$train(task, resampling_idx[[j]]$train)
        predictions <- lrn_knn$predict(task, resampling_idx[[j]]$test)
        ge_est <- ge_est + (1 / folds) * predictions$score()
    }
    tuning_archive[iteration == i]$ge <- ge_est
    
}

ggplot(tuning_archive, aes(x = k, y = ge)) +
    geom_line() +
    geom_point(
        tuning_archive[which.min(tuning_archive$ge)], 
        mapping = aes(x = k, y = ge),
        col = "blue",
        size = 5
)
