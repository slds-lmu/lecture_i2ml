library(mlr3)
library(mlr3learners)
library(mlr3viz)
library(mlbench)

data <- as.data.frame(mlbench.spirals(500, sd = 0.1))
task <- TaskClassif$new(id = "spirals", backend = data, target = "classes")

num_trees <- c(1, 10, 20, 100, 1000)

set.seed(123)
nt <- 5000
for (nt in num_trees) {
  print(plot_learner_prediction(
    learner = lrn("classif.ranger", num.trees = nt), 
    task = task))
  BBmisc::pause()
}

plot_learner_prediction(
  learner = lrn("classif.ranger", num.trees = nt), 
  task = task)

# For a single tree, one observes a very non-smooth decision boundary 
# as one would expect. The decision boundary becomes smoother with an 
# increasing number of trees since bagging reduces the variance of the 
# single classifier. Increasing the number of trees, when the number is 
# already relatively high, does not affect the boundaries much, since the 
# random forest has already converged.

