library(mlr3)
library(mlr3learners)
library(mlr3pipelines)
library(mlr3tuning)
library(mlr3viz)
library(ggplot2)
library(data.table)
library(gridExtra)
library(grid)

set.seed(123)

# Define the Random Forest learners, one for classification, one for regression
learner_rf_classif = lrn("classif.ranger")
learner_rf_regr = lrn("regr.ranger")

# Our tasks
task_classif = tsk("spam")
task_regr = tsk("mtcars")

# Define the parameter sets for tuning ntrees
param_set_ntrees_classif = ParamSet$new(list(
  ParamInt$new("num.trees", lower = 1, upper = 500)
))

param_set_ntrees_regr = ParamSet$new(list(
  ParamInt$new("num.trees", lower = 1, upper = 500)
))

# We use a grid_search to benchmark
tuner = tnr("grid_search", resolution = 30)

# Simple 3-fold CV
resampling = rsmp("cv", folds = 3)

# Perform tuning & benchmarking for classification
at_classif = AutoTuner$new(
  learner = learner_rf_classif,
  resampling = resampling,
  measure = msr("classif.ce"),
  search_space = param_set_ntrees_classif,
  terminator = trm("evals", n_evals = 30),
  tuner = tuner
)
at_classif$train(task_classif)

# Perform tuning & benchmarking for regression
at_regr = AutoTuner$new(
  learner = learner_rf_regr,
  resampling = resampling,
  measure = msr("regr.mse"),
  search_space = param_set_ntrees_regr,
  terminator = trm("evals", n_evals = 30),
  tuner = tuner
)
at_regr$train(task_regr)

# Combine results into a single data.table for plotting
results_classif = as.data.table(at_classif$archive)
results_classif$task_id = task_classif$id

results_regr = as.data.table(at_regr$archive)
results_regr$task_id = task_regr$id

# Define size and line size for plotting
base_size <- 45
line_size <- 8
point_size <- 9

# Classification results
p1 <- ggplot(results_classif, aes(x = num.trees, y = classif.ce, color = task_id)) +
  geom_line(size = line_size) +
  geom_point(size = point_size) +
  labs(
    x = "Number of Trees",
    y = "MCE for 3-fold CV",
    color = "Task"
  ) +
  theme_minimal(base_size = base_size) +
  theme(
    plot.title = element_text(size = base_size + 4, face = "bold")
  )

# Regression results
p2 <- ggplot(results_regr, aes(x = num.trees, y = regr.mse, color = task_id)) +
  geom_line(size = line_size) +
  geom_point(size = point_size) +
  labs(
    x = "Number of Trees",
    y = "MSE for 3-fold CV",
    color = "Task"
  ) +
  theme_minimal(base_size = base_size) +
  theme(
    plot.title = element_text(size = base_size + 4, face = "bold")
  )

# Combined plot for the slide
combined_plot <- grid.arrange(
  p1, p2,
  ncol = 2,
  widths = c(1, 1)
)
ggsave("../figure/forest-ntree.png", plot = combined_plot, width = 32, height = 8, dpi = 300)