# this visualises mtry vs error to justify given defaults in the slide
# we want to show: regression:     mtry = p/3
#                  classification: mtry = sqrt(p) 

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

classif_task = tsk("spam")
reg_task = tsk("mtcars")

learner_rf_classif = lrn("classif.ranger")
learner_rf_regr = lrn("regr.ranger")

# define the parameter sets for tuning
param_set_classif = ParamSet$new(list(
  ParamInt$new("mtry", lower = 1, upper = 57) # spam has 57 features
))

param_set_regr = ParamSet$new(list(
  ParamInt$new("mtry", lower = 1, upper = 10) # mtcars has 10 features
))

# we use a grid_search to benchmark
tuner = tnr("grid_search", resolution = 10)

# simple 10-fold cv
resampling = rsmp("cv", folds = 10)

# perform tuning & benchmarking for classification
at_classif = AutoTuner$new(
  learner = learner_rf_classif,
  resampling = resampling,
  measure = msr("classif.ce"),
  search_space = param_set_classif,
  terminator = trm("evals", n_evals = 10),
  tuner = tuner
)

at_classif$train(classif_task)
classif_results = as.data.table(at_classif$archive)
classif_results$task_id = classif_task$id

# perform tuning & benchmarking for regression
at_regr = AutoTuner$new(
  learner = learner_rf_regr,
  resampling = resampling,
  measure = msr("regr.mse"),
  search_space = param_set_regr,
  terminator = trm("evals", n_evals = 10),
  tuner = tuner
)

at_regr$train(reg_task)
reg_results = as.data.table(at_regr$archive)
reg_results$task_id = reg_task$id

# calculate sensible defaults
p_classif = 57
p_regr = 10

default_classif = sqrt(p_classif)
default_regr = p_regr / 3

# add percentage of mtry relative to number of features
classif_results$percentage_mtry = classif_results$mtry / p_classif * 100
reg_results$percentage_mtry = reg_results$mtry / p_regr * 100

# defines size and line size for plotting
base_size <- 25
line_size <- 3
point_size <- 6

# classification results
p1 <- ggplot(classif_results, aes(x = percentage_mtry, y = classif.ce, color = task_id)) +
  geom_line(linewidth = line_size) +
  geom_point(size = point_size) +
  geom_vline(xintercept = default_classif / p_classif * 100, linetype = "dashed", color = "blue", size=1) +
  labs(
    x = "mtry as percentage of total features",
    y = "MCE for 10-fold CV",
    color = "Task",
  ) +
  theme_minimal(base_size = base_size) +
  theme(
    plot.title = element_text(size = base_size + 4, face = "bold")
  )

# regression results
p2 <- ggplot(reg_results, aes(x = percentage_mtry, y = regr.mse, color = task_id)) +
  geom_line(linewidth = line_size) +
  geom_point(size = point_size) +
  geom_vline(xintercept = default_regr / p_regr * 100, linetype = "dashed", color = "blue", size = 1) +
  labs(
    x = "mtry as percentage of total features",
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
ggsave("../figure/forest-mtry.png", plot = combined_plot, width = 16, height = 8, dpi = 300)
