# goal here is to visualize minnode and justify defaults in the slide

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

# define the Random Forest learners, one for classification, one for regression
learner_rf_classif = lrn("classif.ranger")
learner_rf_regr = lrn("regr.ranger")

# our tasks
task_classif = tsk("spam")
task_regr = tsk("mtcars")

# number of instances
num_instances_classif = task_classif$nrow
num_instances_regr = task_regr$nrow

# define the parameter sets for tuning min.node.size
param_set_minnode_classif = ParamSet$new(list(
  ParamInt$new("min.node.size", lower = 1, upper = round(num_instances_classif * 0.1))
))

param_set_minnode_regr = ParamSet$new(list(
  ParamInt$new("min.node.size", lower = 1, upper = round(num_instances_regr * 0.1))
))

# we use a grid_search to benchmark
tuner = tnr("grid_search", resolution = 30)

# simple 10-fold cv
resampling = rsmp("cv", folds = 10)

# perform tuning & benchmarking for classification
at_classif = AutoTuner$new(
  learner = learner_rf_classif,
  resampling = resampling,
  measure = msr("classif.ce"),
  search_space = param_set_minnode_classif,
  terminator = trm("evals", n_evals = 30),
  tuner = tuner
)
at_classif$train(task_classif)

# perform tuning & benchmarking for regression
at_regr = AutoTuner$new(
  learner = learner_rf_regr,
  resampling = resampling,
  measure = msr("regr.mse"),
  search_space = param_set_minnode_regr,
  terminator = trm("evals", n_evals = 17),
  tuner = tuner
)
at_regr$train(task_regr)

# combine results into a single data.table for plotting
results_classif = as.data.table(at_classif$archive)
results_classif$task_id = task_classif$id
results_classif$min.node.size.percent = (results_classif$min.node.size / num_instances_classif) * 100

results_regr = as.data.table(at_regr$archive)
results_regr$task_id = task_regr$id
results_regr$min.node.size.percent = (results_regr$min.node.size / num_instances_regr) * 100

# defines size and line size for plotting
base_size <- 45
line_size <- 8
point_size <- 9

# classification results
p1 <- ggplot(results_classif, aes(x = min.node.size.percent, y = classif.ce, color = task_id)) +
  geom_line(size = line_size) +
  geom_point(size = point_size) +
  labs(
    x = "min.node.size (%)",
    y = "MCE for 10-fold CV",
    color = "Task",
  ) +
  theme_minimal(base_size = base_size) +
  theme(
    plot.title = element_text(size = base_size + 4, face = "bold")
  )

# regression results
p2 <- ggplot(results_regr, aes(x = min.node.size.percent, y = regr.mse, color = task_id)) +
  geom_line(size = line_size) +
  geom_point(size = point_size) +
  labs(
    x = "min.node.size (%)",
    y = "MSE for 10-fold CV",
    color = "Task",
  ) +
  theme_minimal(base_size = base_size) +
  theme(
    plot.title = element_text(size = base_size + 4, face = "bold")
  )

# combined plot for the slide
combined_plot <- grid.arrange(
  p1, p2,
  ncol = 2,
  widths = c(1, 1)
)
ggsave("../figure/forest-minnode.png", plot = combined_plot, width = 32, height = 8, dpi = 300)