# goal here is to introduce classification tasks: can be binary or multiclass 
# PCA is used to create prettier decision regions

library(mlr3)
library(mlr3learners)
library(mlr3viz)
library(ggplot2)
library(gridExtra)
library(mlr3verse)
library(dplyr)

set.seed(123)
# binary classification: we use the Sonar task, and PCA for dimensionality reduction
binary_task <- as_task_classif(mlr3::tsk("sonar"), target = "Class")
binary_task <- po("pca", rank. = 2)$train(list(binary_task))[[1]]

learner_bin <- lrn("classif.rpart", predict_type = "response")
learner_bin$train(binary_task)

x_range_bin <- seq(min(binary_task$data()$PC1) - 1, max(binary_task$data()$PC1) + 1, length.out = 100)
y_range_bin <- seq(min(binary_task$data()$PC2) - 1, max(binary_task$data()$PC2) + 1, length.out = 100)
grid_bin <- expand.grid(PC1 = x_range_bin, PC2 = y_range_bin)
pred_grid_bin <- learner_bin$predict_newdata(as.data.table(grid_bin))$response
grid_bin$Class <- as.factor(pred_grid_bin)

data_bin <- binary_task$data()
gg_bin <- ggplot() +
  geom_point(data = grid_bin, aes(x = PC1, y = PC2, color = Class), alpha = 0.3) + scale_color_manual(values = c("#E69F00", "#56B4E9")) + xlab(expression(x[1])) + ylab(expression(x[2])) +
  geom_point(data = data_bin, aes(x = PC1, y = PC2, color = Class)) + scale_color_manual(values = c("#E69F00", "#56B4E9")) +
  ggtitle("Sonar: binary classification") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

# multiclass: we use the Iris task, again using PCA for dimensionality reduction
multiclass_task <- as_task_classif(mlr3::tsk("iris"), target = "Species")
multiclass_task <- po("pca", rank. = 2)$train(list(multiclass_task))[[1]]

learner_multi <- lrn("classif.ranger", predict_type = "response")
learner_multi$train(multiclass_task)

x_range_multi <- seq(min(multiclass_task$data()$PC1) - 1, max(multiclass_task$data()$PC1) + 1, length.out = 100)
y_range_multi <- seq(min(multiclass_task$data()$PC2) - 1, max(multiclass_task$data()$PC2) + 1, length.out = 100)
grid_multi <- expand.grid(PC1 = x_range_multi, PC2 = y_range_multi)
pred_grid_multi <- learner_multi$predict_newdata(as.data.table(grid_multi))$response
grid_multi$Species <- as.factor(pred_grid_multi)

data_multi <- multiclass_task$data()
gg_multi <- ggplot() +
  geom_point(data = grid_multi, aes(x = PC1, y = PC2, color = Species), alpha = 0.3) + xlab(expression(x[1])) + ylab(expression(x[2])) +
  geom_point(data = data_multi, aes(x = PC1, y = PC2, color = Species)) +
  ggtitle("Iris: multiclass classification") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

# combining the plots
combined_plot <- grid.arrange(gg_bin, gg_multi, ncol = 2)

# saving
ggsave("../figure/tasks-combined.png", plot = combined_plot, width = 16, height = 6, units = "in")
ggsave("../figure/tasks-bc.png", plot = gg_bin, width = 8, height = 6, units = "in")
