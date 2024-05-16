# this visualises maxdepth vs error to justify given default (infinity for maxdepth) in the slide

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
task_classif = tsk("sonar")
task_regr = tsk("boston_housing")

# define the parameter sets for tuning maxdepth
param_set_maxdepth_classif = ParamSet$new(list(
  ParamInt$new("max.depth", lower = 1, upper = 60) # 60 features in sonar
))

param_set_maxdepth_regr = ParamSet$new(list(
  ParamInt$new("max.depth", lower = 1, upper = 17) # 17 in boston_housing
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
  search_space = param_set_maxdepth_classif,
  terminator = trm("evals", n_evals = 30),
  tuner = tuner
)
at_classif$train(task_classif)

# perform tuning & benchmarking for regression
at_regr = AutoTuner$new(
  learner = learner_rf_regr,
  resampling = resampling,
  measure = msr("regr.mse"),
  search_space = param_set_maxdepth_regr,
  terminator = trm("evals", n_evals = 17),
  tuner = tuner
)
at_regr$train(task_regr)

# combine results into a single data.table for plotting
results_classif = as.data.table(at_classif$archive)
results_classif$task_id = task_classif$id

results_regr = as.data.table(at_regr$archive)
results_regr$task_id = task_regr$id

# defines size and line size for plotting
base_size <- 45
line_size <- 8
point_size <- 9

# classification results
p1 <- ggplot(results_classif, aes(x = max.depth, y = classif.ce, color = task_id)) +
  geom_line(size = line_size) +
  geom_point(size = point_size) +
  labs(
    x = "max.depth",
    y = "Misclassification Error",
    color = "Task",
  ) +
  theme_minimal(base_size = base_size) +
  theme(
    plot.title = element_text(size = base_size + 4, face = "bold")
  )

# regression results
p2 <- ggplot(results_regr, aes(x = max.depth, y = regr.mse, color = task_id)) +
  geom_line(size = line_size) +
  geom_point(size = point_size) +
  labs(
    x = "max.depth",
    y = "Mean Squared Error",
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
  widths = c(1, 1),
  bottom = textGrob(
    "sonar has 60 features, boston_housing 17",
    gp = gpar(fontsize = base_size)
  )
)
ggsave("../figure/forest-maxdepth.png", plot = combined_plot, width = 32, height = 8, dpi = 300)
