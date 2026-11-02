library(mlbench)
library(kernlab)
library(knitr)
library(ggplot2)
library(mlr3)
library(mlr3learners)
library(mlr3viz)
library(gridExtra)
library(patchwork)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# DATA -------------------------------------------------------------------------
set.seed(6)
data = mlbench.twonorm(n = 50, d = 2)
data = as.data.frame(data)
X = as.matrix(data[, 1:2])
y = data$classes
colnames(data) <- c("x.1", "x.2", "Class")
data$Class <- as.numeric(data$Class)
data[data$Class == 2,3] <- 0
data$Class <- as.factor(data$Class)

task = TaskClassif$new("data_binary", data, target = "Class")
task$select(c("x.1", "x.2"))

# PLOT LOG REGRESSION --------------------------------------------------------------------

learner = lrn("classif.log_reg", predict_type = "prob")

features = task$feature_names
predict_sets = "train"
task$data(cols = features)
rr = mlr3::resample(task, learner$clone(), mlr3::rsmp("holdout", ratio = 1), store_models = TRUE)
grid = mlr3viz:::predict_grid(rr$learners, rr$task, grid_points = 100L, expand_range = 0)
data = mlr3viz:::task_data(rr, predict_sets)
data$.predict_set <- as.numeric(data$.predict_set)

plot_log_reg <- ggplot(grid, aes(
  x = .data[[features[1L]]], 
  y = .data[[features[2L]]])
) + 
  geom_raster(aes(fill = .data[["response"]], alpha = .data[[".prob.response"]])) + 
  geom_point(
    data = mlr3viz:::task_data(rr, predict_sets),size=3, 
    aes(shape = .data[["Class"]], fill = .data[["Class"]],  color=.data[["Class"]]), color = "black") +
  scale_fill_hue() + 
  scale_shape_manual(values = c(21,24)) +
  #guides + 
  scale_alpha_continuous(name = "Probability") + 
  labs(fill = "Class") + 
  guides(alpha = FALSE, color = guide_legend(
    override.aes=list(shape = 19))) +
  ggtitle("Logistic Regession \n (Discriminant Approach") +
  theme(axis.text=element_text(size=14),title=element_text(size = 16), axis.title=element_text(size=14), 
        legend.key.size = unit(1.5, 'cm'), legend.title = element_text(size=14),
        legend.text = element_text(size=14), legend.title.align=0.3, legend.position = "right")


# PLOT NAIVE BAYES --------------------------------------------------------------------

learner = lrn("classif.naive_bayes", predict_type = "prob")

features = task$feature_names
predict_sets = "train"
task$data(cols = features)
rr = mlr3::resample(task, learner$clone(), mlr3::rsmp("holdout", ratio = 1), store_models = TRUE)
grid = mlr3viz:::predict_grid(rr$learners, rr$task, grid_points = 100L, expand_range = 0)
data = mlr3viz:::task_data(rr, predict_sets)
data$.predict_set <- as.numeric(data$.predict_set)

plot_naive_bayes <- ggplot(grid, aes(
  x = .data[[features[1L]]], 
  y = .data[[features[2L]]])
) + 
  geom_raster(aes(fill = .data[["response"]], alpha = .data[[".prob.response"]])) + 
  geom_point(
    data = mlr3viz:::task_data(rr, predict_sets),size=3, 
    aes(shape = .data[["Class"]], fill = .data[["Class"]],  color=.data[["Class"]]), color = "black") +
  scale_fill_hue() + 
  scale_shape_manual(values = c(21,24)) +
  #guides + 
  scale_alpha_continuous(name = "Probability") + 
  labs(fill = "Class") + 
  guides(alpha = FALSE, color = guide_legend(
    override.aes=list(shape = 19))) +
  ggtitle("Naive Bayes \n (Generative Approach") +
  theme(axis.text=element_text(size=14),title=element_text(size = 16), axis.title=element_text(size=14), 
        legend.key.size = unit(1.5, 'cm'), legend.title = element_text(size=14),
        legend.text = element_text(size=14), legend.title.align=0.3, legend.position = "right")


 
#guide_legend(title="New Legend Title")
# PLOT -------------------------------------------------------------------------

combined_plot <-  plot_log_reg + plot_naive_bayes +
  plot_layout(guides = "collect") 

ggsave("figure/nutshell_classif_binary_task.png", plot = combined_plot, width = 9, height = 4)

