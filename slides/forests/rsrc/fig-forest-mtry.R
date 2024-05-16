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

# define tasks
classif_tasks = lapply(c("wine", "sonar"), tsk)
reg_tasks = lapply(c("boston_housing", "mtcars"), tsk)

# define Random Forest learners
learner_rf_classif = lrn("classif.ranger")
learner_rf_regr = lrn("regr.ranger")

# define the parameter sets for tuning
param_set_regr = ParamSet$new(list(
  ParamInt$new("mtry", lower = 1, upper = 10) # mtcars has 10 features, boston_housing 17
))

param_set_classif = ParamSet$new(list(
  ParamInt$new("mtry", lower = 1, upper = 13) # wine has 13 features, sonar 60
))

# we use a grid_search to benchmark
tuner = tnr("grid_search", resolution = 10)

# simple 10-fold cv
resampling = rsmp("cv", folds = 10)

# perform tuning & benchmarking for classification
classif_results_list = list()
for (task in classif_tasks) {
  at = AutoTuner$new(
    learner = learner_rf_classif,
    resampling = resampling,
    measure = msr("classif.ce"),
    search_space = param_set_classif,
    terminator = trm("evals", n_evals = 10),
    tuner = tuner
  )
  
  at$train(task)
  results = as.data.table(at$archive)
  results$task_id = task$id
  classif_results_list[[task$id]] = results
}

# perform tuning & benchmarking for regression
reg_results_list = list()
for (task in reg_tasks) {
  at = AutoTuner$new(
    learner = learner_rf_regr,
    resampling = resampling,
    measure = msr("regr.mse"),
    search_space = param_set_regr,
    terminator = trm("evals", n_evals = 10),
    tuner = tuner
  )
  
  at$train(task)
  results = as.data.table(at$archive)
  results$task_id = task$id
  reg_results_list[[task$id]] = results
}


# combine results into a single data.table for plotting
classif_results_dt = rbindlist(classif_results_list)
reg_results_dt = rbindlist(reg_results_list)

# defines size and line size for plotting
base_size <- 25
line_size <- 3
point_size <- 6

# classification results
p1 <- ggplot(classif_results_dt, aes(x = mtry, y = classif.ce, color = task_id)) +
  geom_line(size = line_size) +
  geom_point(size = point_size) +
  labs(
    x = "mtry",
    y = "Misclassification Error",
    color = "Task",
  ) +
  theme_minimal(base_size = base_size) +
  theme(
    plot.title = element_text(size = base_size + 4, face = "bold")
  )

# regression results
p2 <- ggplot(reg_results_dt, aes(x = mtry, y = regr.mse, color = task_id)) +
  geom_line(size = line_size) +
  geom_point(size = point_size) +
  labs(
    x = "mtry",
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
    "mtcars: 10 features | boston_housing: 17 features | wine: 13 features | sonar: 60 features",
    gp = gpar(fontsize = base_size)
  )
)
ggsave("forest-mtry.png", plot = combined_plot, width = 16, height = 8, dpi = 300)
