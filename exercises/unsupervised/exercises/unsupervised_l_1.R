library(mlr3)
library(mlr3pipelines)
library(mlr3viz)


# Save tasks in list
tasks = list(tsk("sonar"), tsk("spam"))

# Create two learners
# 1) a regular tree (default params)
# 2) a simple pipeline pca -> tree
lrns = list(
  lrn("classif.rpart"),
  GraphLearner$new(po("pca") %>>% lrn("classif.rpart"))
)

# run the benchmark
set.seed(123)
grid = benchmark_grid(tasks, lrns, rsmp("cv", folds = 10))

res = benchmark(grid)
autoplot(res)
