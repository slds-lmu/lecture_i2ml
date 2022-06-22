# PREREQ -----------------------------------------------------------------------

library(knitr)
library(mlr3)
library(mlr3learners)
library(mlr3viz)
library(ggplot2)
library(gridExtra)
library(patchwork)
library(cowplot)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# DATA -------------------------------------------------------------------------
task = tsk("iris")
task$select(c("Sepal.Width", "Sepal.Length"))
df_iris = task$data(data_format = "data.table")
num_trees = c(1, 2, 5, 10, 500)

set.seed(123)
train_set1 = sample(task$nrow, 0.9 * task$nrow)
task_train1 = TaskClassif$new(id = "my_iris", 
                              backend = df_iris[train_set1,], # use train_set
                              target = "Species")
set.seed(456)
train_set2 = sample(task$nrow, 0.9 * task$nrow)
task_train2 = TaskClassif$new(id = "my_iris", 
                              backend = df_iris[train_set2,], # use train_set
                              target = "Species")

common_indices <- intersect(train_set1, train_set2)
indices_set1 = setdiff(train_set1, common_indices)
indices_set2 = setdiff(train_set2, common_indices)
oob_indices1 <- setdiff(1:nrow(df_iris), train_set1)
oob_indices2 <- setdiff(1:nrow(df_iris), train_set2)
df_iris[common_indices,'Dataset'] <- "In both datasets"
df_iris[indices_set1,'Dataset'] <- "Only in 1st dataset"
df_iris[indices_set2,'Dataset'] <- "Only in 2nd dataset"

print(length(common_indices))
nrow(df_iris)
# LEARNERS RNDF ----------------------------------------------------------------
learners = lapply(num_trees, 
                  function (i) {lrn("classif.ranger",
                                    num.trees = i, 
                                    predict_type = "prob")})

learner = lrn("classif.rpart", predict_type = "prob")
# PLOT AND SAVE LEARNERS -------------------------------------------------------
pdf("../figure/cart_forest_overview_1.pdf", width = 12, height = 5.5)
#plot1 <- plot_learner_prediction(learners[[1]], task) + 
#  guides(shape = FALSE, alpha = FALSE) +
#  scale_color_viridis_d() + 
#  scale_fill_viridis_d(end = .9)

#plot2 <- plot_learner_prediction(learners[[1]], task) + 
#  guides(shape = FALSE, alpha = FALSE) +
#  scale_color_viridis_d() + 
#  scale_fill_viridis_d(end = .9)
plot1 <- plot_learner_prediction(learners[[1]], task_train1) +
  guides(shape = FALSE, alpha = FALSE) +
    scale_color_viridis_d() + 
    scale_fill_viridis_d(end = .9)

plot2 <- plot_learner_prediction(learners[[2]], task_train2) +
  guides(shape = FALSE, alpha = FALSE) +
  scale_color_viridis_d() + 
  scale_fill_viridis_d(end = .9)
#plt3 <- grid.arrange(plot1, plot2, ncol=2) 
(plot1 + plot2)
ggsave("../figure/cart_forest_overview_1.pdf", width = 12, height = 5.5)
dev.off()

pdf("../figure/cart_forest_overview_2.pdf", width = 8, height = 5.5)
plot3 <- plot_learner_prediction(learners[[2]], task) + 
  guides(shape = FALSE, alpha = FALSE) +
  scale_color_viridis_d() + 
  scale_fill_viridis_d(end = .9)
print(plot3)
ggsave("../figure/cart_forest_overview_2.pdf", width = 8, height = 5.5)
dev.off()

pdf("../figure/cart_forest_overview_3.pdf", width = 8, height = 5.5)
plot3 <- plot_learner_prediction(learners[[3]], task) + 
  guides(shape = FALSE, alpha = FALSE) +
  scale_color_viridis_d() + 
  scale_fill_viridis_d(end = .9)
print(plot3)
ggsave("../figure/cart_forest_overview_3.pdf", width = 8, height = 5.5)
dev.off()

pdf("../figure/cart_forest_overview_4.pdf", width = 8, height = 5.5)
plot4 <- plot_learner_prediction(learners[[4]], task) + 
  guides(shape = FALSE, alpha = FALSE) +
  scale_color_viridis_d() + 
  scale_fill_viridis_d(end = .9)
print(plot4)
ggsave("../figure/cart_forest_overview_4.pdf", width = 8, height = 5.5)
dev.off()

pdf("../figure/cart_forest_overview_5.pdf", width = 8, height = 5.5)
plot5 <- plot_learner_prediction(learners[[5]], task) + 
  guides(shape = FALSE, alpha = FALSE) +
  scale_color_viridis_d() + 
  scale_fill_viridis_d(end = .9)
print(plot5)
ggsave("../figure/cart_forest_overview_5.pdf", width = 8, height = 5.5)
dev.off()

pdf("../figure/cart_forest_overview_6.pdf", width = 8, height = 5.5)
plot1_1 <- plot1 + labs(caption = "Result of 1 learner") + theme(plot.caption = element_text(hjust = 0))
plot3_1 <- plot3 + labs(caption = "Aggregated result of 5 learners") + theme(plot.caption = element_text(hjust = 0))
plot4_1 <- plot4 + labs(caption = "Aggregated result of 10 learners") + theme(plot.caption = element_text(hjust = 0))
plot5_1 <- plot5 + labs(caption = "Aggregated result of 500 learners") +theme(plot.caption = element_text(hjust = 0))
grid.arrange(plot1_1, plot3_1, plot4_1, plot5_1, ncol = 2, nrow = 2)
ggsave("../figure/cart_forest_overview_6.pdf", width = 8, height = 5.5)
dev.off()

pdf("../figure/cart_forest_overview_bs_datasets.pdf", width = 8, height = 5.5)
df_iris_tmp <- df_iris
df_iris_tmp$Dataset[is.na(df_iris_tmp$Dataset)] <- "In neither of the two datasets"
plt <- ggplot() + 
  geom_point(data = df_iris_tmp, mapping = aes(x = Sepal.Length, y = Sepal.Width, shape = Dataset)) +
  scale_color_viridis_d() + scale_fill_viridis_d(end = .9)
print(plt)
ggsave("../figure/cart_forest_overview_bs_datasets.pdf", width = 8, height = 5.5)
dev.off()

pdf("../figure/cart_forest_overview_oob_datasets.pdf", width = 8, height = 5.5)
df_iris_tmp1 <- df_iris_tmp
df_iris_tmp2 <- df_iris_tmp
df_iris_tmp1[train_set1, "Datapoints"] <- "Bootstrapped datapoints"
df_iris_tmp1[oob_indices1, "Datapoints"] <- "Data points used for OOB"

df_iris_tmp2[train_set2, "Datapoints"] <- "Bootstrapped datapoints"
df_iris_tmp2[oob_indices2, "Datapoints"] <- "Data points used for OOB"

plot1 <- ggplot() + 
  geom_point(data = df_iris_tmp1, mapping = aes(x = Sepal.Length, y = Sepal.Width, color = Datapoints)) +
  scale_color_viridis_d() + scale_fill_viridis_d(end = .9) + theme(legend.position="bottom")
legend <- get_legend(plot1)
plot2 <- ggplot() + 
  geom_point(data = df_iris_tmp2, mapping = aes(x = Sepal.Length, y = Sepal.Width, color = Datapoints)) +
  scale_color_viridis_d() + scale_fill_viridis_d(end = .9) + theme(legend.position="none")
plot1 + theme(legend.position="bottom") +plot2+plot_layout(guides = "collect") + theme(legend.position = 'bottom', legend.title=element_blank())

ggsave("../figure/cart_forest_overview_oob_datasets.pdf", width = 8, height = 5.5)
dev.off()
