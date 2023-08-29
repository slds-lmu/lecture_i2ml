# PREREQ -----------------------------------------------------------------------

library(knitr)
library(mlr3)
library(mlr3learners)
library(mlr3viz)
library(ggplot2)
library(ISLR)
library(mlbench)
library(kernlab)
library(knitr)
library(gridExtra)
library(patchwork)


credit_data <- Credit
credit_data <- credit_data[, c("Rating", "Age","Income",  "Limit", "Balance")]


options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# DATA -------------------------------------------------------------------------



set.seed(600000)
task = TaskRegr$new("credit_task", 
                    backend = credit_data, 
                    target = "Balance"
)
task$select(c("Limit"))


num_trees = c(1, 50, 50000)

learners = lapply(num_trees, 
                  function (i) {lrn("regr.ranger",
                                    num.trees = i)}) 




# PLOT 1 -----------------------------------------------------------------------

plot1 <- plot_learner_prediction(learners[[1]], task) +
  ggtitle(paste0(num_trees[1], " Tree(s) for Credit  Dataset")) +
  guides(shape = FALSE, alpha = FALSE) + theme(axis.text=element_text(size=18),title=element_text(size = 22), axis.title=element_text(size=22), 
                                               legend.key.size = unit(1.5, 'cm'), legend.position = "none") +
  xlab("Limit") + ylab("Balance") 

ggsave(plot = plot1, "figure/nutshell_forest_ensemblesize_1.pdf", width = 8, height = 5.5)


# PLOT 2 -----------------------------------------------------------------------

plot2 <- plot_learner_prediction(learners[[2]], task) +
  ggtitle(paste0(num_trees[2], " Tree(s) for Credit  Dataset")) +
  guides(shape = FALSE, alpha = FALSE) + theme(axis.text=element_text(size=18),title=element_text(size = 22), axis.title=element_text(size=22), 
                                               legend.key.size = unit(1.5, 'cm'), legend.position = "none") +
  xlab("Limit") + ylab("Balance") 

ggsave(plot = plot2, "figure/nutshell_forest_ensemblesize_2.pdf", width = 8, height = 5.5)


# PLOT 3 -----------------------------------------------------------------------

plot3 <- plot_learner_prediction(learners[[3]], task) +
  ggtitle(paste0(num_trees[3], " Tree(s) for Credit  Dataset")) +
  guides(shape = FALSE, alpha = FALSE) + theme(axis.text=element_text(size=18),title=element_text(size = 22), axis.title=element_text(size=22), 
                                               legend.key.size = unit(1.5, 'cm'), legend.position = "none") +
  xlab("Limit") + ylab("Balance") 

ggsave(plot = plot3, "figure/nutshell_forest_ensemblesize_3.pdf", width = 8, height = 5.5)


# PLOT RF CLASSIFICATION

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# DATA -------------------------------------------------------------------------
set.seed(6)
data = mlbench.twonorm(n = 100, d = 2)
data = as.data.frame(data)
X = as.matrix(data[, 1:2])
y = data$classes
colnames(data) <- c("x.1", "x.2", "Class")
data$Class <- as.numeric(data$Class)
data[data$Class == 2,3] <- 0
data$Class <- as.factor(data$Class)

task = TaskClassif$new("data_binary", data, target = "Class")
task$select(c("x.1", "x.2"))

# FUNCTIONS --------------------------------------------------------------------

num_trees = c(1, 10, 200)

learners_list = lapply(num_trees, 
                       function (i) {lrn("classif.ranger",
                                         num.trees = i, predict_type = "prob")}) 



# PLOT 1 CLASSIFICTAION -TREE 1 --------------------------------------------------------------------
set.seed(2)
features = task$feature_names
predict_sets = "train"
task$data(cols = features)
rr = mlr3::resample(task, learners_list[[1]]$clone(), mlr3::rsmp("holdout", ratio = 1), store_models = TRUE)
grid = mlr3viz:::predict_grid(rr$learners, rr$task, grid_points = 100L, expand_range = 0)
data = mlr3viz:::task_data(rr, predict_sets)
data$.predict_set <- as.numeric(data$.predict_set)


plot1 <- ggplot(grid, aes(
  x = .data[[features[1L]]], 
  y = .data[[features[2L]]])
) + 
  geom_raster(aes(fill = .data[["response"]], alpha = .data[[".prob.response"]])) + 
  geom_point(
    data = mlr3viz:::task_data(rr, predict_sets),size=3, 
    aes(shape = .data[["Class"]], fill = .data[["Class"]],  color=.data[["Class"]]), color = "black") +
  scale_fill_hue() + 
  scale_shape_manual(values = c(21,24)) +
  scale_alpha_continuous(name = "Probability") + 
  labs(fill = "Class") + 
  guides(alpha = FALSE, color = guide_legend(
    override.aes=list(shape = 19))) +
  ggtitle(paste0(num_trees[1], " Random Tree for Classification Task")) +
  theme(axis.text=element_text(size=14),title=element_text(size = 16), axis.title=element_text(size=14), 
        legend.key.size = unit(2.5, 'cm'), legend.title = element_text(size=14),
        legend.text = element_text(size=14), legend.title.align=0.3, legend.position = "right")
ggsave(plot = plot1, "figure/nutshell_classif_forest_ensemblesize_1.pdf", width = 8, height = 5.5)

# PLOT 1 CLASSIFICATION - TREE 2 --------------------------------------------------------------------
set.seed(30)
features = task$feature_names
predict_sets = "train"
task$data(cols = features)
rr = mlr3::resample(task, learners_list[[1]]$clone(), mlr3::rsmp("holdout", ratio = 1), store_models = TRUE)
grid = mlr3viz:::predict_grid(rr$learners, rr$task, grid_points = 100L, expand_range = 0)
data = mlr3viz:::task_data(rr, predict_sets)
data$.predict_set <- as.numeric(data$.predict_set)

plot1_2 <- ggplot(grid, aes(
  x = .data[[features[1L]]], 
  y = .data[[features[2L]]])
) + 
  geom_raster(aes(fill = .data[["response"]], alpha = .data[[".prob.response"]])) + 
  geom_point(
    data = mlr3viz:::task_data(rr, predict_sets),size=3, 
    aes(shape = .data[["Class"]], fill = .data[["Class"]],  color=.data[["Class"]]), color = "black") +
  scale_fill_hue() + 
  scale_shape_manual(values = c(21,24)) +
  scale_alpha_continuous(name = "Probability") + 
  labs(fill = "Class") + 
  guides(alpha = FALSE, color = guide_legend(
    override.aes=list(shape = 19))) +
  ggtitle(paste0(num_trees[1], "  Random Tree for Classification Task")) +
  theme(axis.text=element_text(size=14),title=element_text(size = 16), axis.title=element_text(size=14), 
        legend.key.size = unit(2.5, 'cm'), legend.title = element_text(size=14),
        legend.text = element_text(size=14), legend.title.align=0.3, legend.position = "right")
ggsave(plot = plot1_2, "figure/nutshell_classif_forest_ensemblesize_1_TREE_2.pdf", width = 8, height = 5.5)

# PLOT 2 CLASSIFICATION
set.seed(2)
features = task$feature_names
predict_sets = "train"
task$data(cols = features)
rr = mlr3::resample(task, learners_list[[2]]$clone(), mlr3::rsmp("holdout", ratio = 1), store_models = TRUE)
grid = mlr3viz:::predict_grid(rr$learners, rr$task, grid_points = 100L, expand_range = 0)
data = mlr3viz:::task_data(rr, predict_sets)
data$.predict_set <- as.numeric(data$.predict_set)


plot2 <- ggplot(grid, aes(
  x = .data[[features[1L]]], 
  y = .data[[features[2L]]])
) + 
  geom_raster(aes(fill = .data[["response"]], alpha = .data[[".prob.response"]])) + 
  geom_point(
    data = mlr3viz:::task_data(rr, predict_sets),size=3, 
    aes(shape = .data[["Class"]], fill = .data[["Class"]],  color=.data[["Class"]]), color = "black") +
  scale_fill_hue() + 
  scale_shape_manual(values = c(21,24)) +
  scale_alpha_continuous(name = "Probability") + 
  labs(fill = "Class") + 
  guides(alpha = FALSE, color = guide_legend(
    override.aes=list(shape = 19))) +
  ggtitle(paste0(num_trees[2], " Random Trees for Classification Task")) +
  theme(axis.text=element_text(size=14),title=element_text(size = 16), axis.title=element_text(size=14), 
        legend.key.size = unit(1.5, 'cm'), legend.title = element_text(size=14),
        legend.text = element_text(size=14), legend.title.align=0.3, legend.position = "right")

ggsave(plot = plot2, "figure/nutshell_classif_forest_ensemblesize_2.pdf", width = 8, height = 5.5)

# PLOT 3 CLASSIFICATION
set.seed(2)
features = task$feature_names
predict_sets = "train"
task$data(cols = features)
rr = mlr3::resample(task, learners_list[[3]]$clone(), mlr3::rsmp("holdout", ratio = 1), store_models = TRUE)
grid = mlr3viz:::predict_grid(rr$learners, rr$task, grid_points = 100L, expand_range = 0)
data = mlr3viz:::task_data(rr, predict_sets)
data$.predict_set <- as.numeric(data$.predict_set)



plot3 <- ggplot(grid, aes(
  x = .data[[features[1L]]], 
  y = .data[[features[2L]]])
) + 
  geom_raster(aes(fill = .data[["response"]], alpha = .data[[".prob.response"]])) + 
  geom_point(
    data = mlr3viz:::task_data(rr, predict_sets),size=3, 
    aes(shape = .data[["Class"]], fill = .data[["Class"]],  color=.data[["Class"]]), color = "black") +
  scale_fill_hue() + 
  scale_shape_manual(values = c(21,24)) +
  scale_alpha_continuous(name = "Probability") + 
  labs(fill = "Class") + 
  guides(alpha = FALSE, color = guide_legend(
    override.aes=list(shape = 19))) +
  ggtitle(paste0(num_trees[3], " Random Trees for Classification Task")) +
  theme(axis.text=element_text(size=14),title=element_text(size = 16), axis.title=element_text(size=14), 
        legend.key.size = unit(2.5, 'cm'), legend.title = element_text(size=14),
        legend.text = element_text(size=14), legend.title.align=0.3, legend.position = "right")

ggsave(plot = plot3, "figure/nutshell_classif_forest_ensemblesize_3.pdf", width = 8, height = 5.5)

# PLOT 3 CLASSIFICATION - TREE 2 --------------------------------------------------------------------

set.seed(30)
features = task$feature_names
predict_sets = "train"
task$data(cols = features)
rr = mlr3::resample(task, learners_list[[3]]$clone(), mlr3::rsmp("holdout", ratio = 1), store_models = TRUE)
grid = mlr3viz:::predict_grid(rr$learners, rr$task, grid_points = 100L, expand_range = 0)
data = mlr3viz:::task_data(rr, predict_sets)
data$.predict_set <- as.numeric(data$.predict_set)



plot3_2 <- ggplot(grid, aes(
  x = .data[[features[1L]]], 
  y = .data[[features[2L]]])
) + 
  geom_raster(aes(fill = .data[["response"]], alpha = .data[[".prob.response"]])) + 
  geom_point(
    data = mlr3viz:::task_data(rr, predict_sets),size=3, 
    aes(shape = .data[["Class"]], fill = .data[["Class"]],  color=.data[["Class"]]), color = "black") +
  scale_fill_hue() + 
  scale_shape_manual(values = c(21,24)) +
  scale_alpha_continuous(name = "Probability") + 
  labs(fill = "Class") + 
  guides(alpha = FALSE, color = guide_legend(
    override.aes=list(shape = 19))) +
  ggtitle(paste0(num_trees[3], " Random Trees for Classification Task")) +
  theme(axis.text=element_text(size=14),title=element_text(size = 16), axis.title=element_text(size=14), 
        legend.key.size = unit(2.5, 'cm'), legend.title = element_text(size=14),
        legend.text = element_text(size=14), legend.title.align=0.3, legend.position = "right")

ggsave(plot = plot3_2, "figure/nutshell_classif_forest_ensemblesize_3_TREE_3.pdf", width = 8, height = 5.5)


combined_plot_1 <-  plot1 + plot1_2 +  plot3 + plot3_2 + plot_layout(guides = "collect") 
combined_plot_2 <-  plot1_2 + plot3_2 + plot_layout(guides = "collect") 

ggsave(plot = combined_plot_1, "figure/nutshell_classif_combined_1.pdf", width = 11, height = 10)
ggsave(plot = combined_plot_2, "figure/nutshell_classif_combined_2.pdf", width = 10, height = 4)


# PLOT K-NN BAGGED

