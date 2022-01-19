library(mlr3)
library(mlr3learners)
library(mlr3viz)
library(mlbench)

data <- as.data.frame(mlbench.spirals(1000, sd = 0.1, cycles = 4))
task <- TaskClassif$new(id = "spirals", backend = data, target = "classes")

num_trees <- c(1, 2, 10, 100, 5000)

set.seed(123)
for (n in num_trees) {
  print(plot_learner_prediction(
    learner = lrn("classif.ranger", num.trees = n),
    task = task))
  # BBmisc::pause() 
}

# We observe increasingly smooth decision boundaries for a growing number of 
# trees. Also, as the problem is fairly hard to classify, it takes quite a 
# number of trees to arrive at an adequate solution.
# Beyond a certain ensemble size, adding more trees does not increase
# performance much more.