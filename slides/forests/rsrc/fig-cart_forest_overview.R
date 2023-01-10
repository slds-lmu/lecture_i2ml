# PREREQ -----------------------------------------------------------------------
library(ggpubr)
library(knitr)
library(mlr3)
library(mlr3learners)
library(mlr3viz)
library(ggplot2)
library(gridExtra)
library(patchwork)
library(cowplot)
library(mlbench)


options(digits = 3,
        width = 65,
        str = strOptions(strict.width = "cut", vec.len = 3))

# DATA -------------------------------------------------------------------------

library(ggplot2)
library(caret)
#shapes <- mlbench.spirals(n=5000,cycles = 2)
#plot(shapes)
#str(shapes)
#shapes$x
#data <- cbind(shapes$x, shapes$classes)

generate_Data <- function(N, D, K, seed) {
  set.seed(seed)
  X <- data.frame()
  y <- data.frame()
  for (j in (1:K)){
    r <- seq(0.05,1,length.out = N) # radius
    t <- seq((j-1)*4.3,j*4.3, length.out = N) + rnorm(N, sd = 0.5) # theta
    Xtemp <- data.frame(x =r*sin(t) , y = r*cos(t))
    ytemp <- data.frame(matrix(j, N, 1))
    X <- rbind(X, Xtemp)
    y <- rbind(y, ytemp)}

  data <- cbind(X,y)
  str(data)
  colnames(data) <- c(colnames(X), 'label')
  data$label <- as.factor(data$label)
  return(data)
}

#library(ggplot2)library(caret) N <- 200 # number of points per classD <- 2 # dimensionalityK <- 4 # number of classesX <- data.frame() # data matrix (each row = single example)y <- data.frame() # class labels set.seed(308) for (j in (1:K)){  r <- seq(0.05,1,length.out = N) # radius  t <- seq((j-1)*4.7,j*4.7, length.out = N) + rnorm(N, sd = 0.3) # theta  Xtemp <- data.frame(x =r*sin(t) , y = r*cos(t))   ytemp <- data.frame(matrix(j, N, 1))  X <- rbind(X, Xtemp)  y <- rbind(y, ytemp)} data <- cbind(X,y)colnames(data) <- c(colnames(X), 'label')

calculateGE <- function(task, learner, test_data){
  learner$train(task)
  pred <- learner$predict_newdata(test_data)
  return(pred$score(measures = msr("classif.ce")))
}

data <- generate_Data(200, 2, 2, 123)
test_data <- generate_Data(1000, 2, 2, 456)
#x_min <- min(X[,1])-0.2;
#x_max <- max(X[,1])+0.2
#y_min <- min(X[,2])-0.2;
#y_max <- max(X[,2])+0.2 # lets visualize the data:
#ggplot(ddata_spiralsata) + geom_point(aes(x=x, y=y, color = as.character(label)), size = 2) + theme_bw(base_size = 15) +  xlim(x_min, x_max) + ylim(y_min, y_max) +  ggtitle('Spiral Data Visulization') +  coord_fixed(ratio = 0.8) +  theme(axis.ticks=element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(),         axis.text=element_blank(), axis.title=element_blank(), legend.position = 'none')

#task = tsk("iris")
#task$select(c("Sepal.Width", "Sepal.Length"))
#df_iris = task$data(data_format = "data.table")
#set.seed(123)
#train_set1 = sample(task$nrow, 0.9 * task$nrow)
#task_train1 = TaskClassif$new(id = "my_iris",
#                              backend = df_iris[train_set1,], # use train_set
#                              target = "Species")
#set.seed(456)
#set.seed(456123)
#train_set2 = sample(task$nrow, 0.9 * task$nrow)
#task_train2 = TaskClassif$new(id = "my_iris",
#                              backend = df_iris[train_set2,], # use train_set
#                              target = "Species")

task_spirals <- TaskClassif$new(id = "sprials",
                                backend = data, # use train_set
                                target = "label")
num_trees = c(1, 3, 10, 100)
set.seed(456)
train_set1 = sample(task_spirals$nrow, 0.8 * task_spirals$nrow, replace = F)
task_train1 = TaskClassif$new(id = "sprials1",
                              backend = data[train_set1,], # use train_set
                              target = "label")
#set.seed(124)
#set.seed(456123)
train_set2 = sample(task_spirals$nrow, 0.8 * task_spirals$nrow, replace = F)
task_train2 = TaskClassif$new(id = "sprials1",
                              backend = data[train_set2, ], # use train_set
                              target = "label")


#set.seed(456)
train_set3 = sample(task_spirals$nrow, 0.8 * task_spirals$nrow, replace = F)
task_train3 = TaskClassif$new(id = "sprials1",
                              backend = data[train_set3, ], # use train_set
                              target = "label")

common_indices <- intersect(train_set1, train_set2)
common_indices <- intersect(common_indices, train_set3)
indices_set1 = setdiff(train_set1, common_indices)
indices_set2 = setdiff(train_set2, common_indices)
indices_set3 = setdiff(train_set3, common_indices)

oob_indices1 <- setdiff(1:nrow(data), train_set1)
oob_indices2 <- setdiff(1:nrow(data), train_set2)
oob_indices3 <- setdiff(1:nrow(data), train_set3)

df_spirals1 <- data
df_spirals1[common_indices,'Dataset'] <- "In all datasets"
df_spirals1[indices_set1,'Dataset'] <- "Only in respective dataset"
df_spirals1[indices_set2,'Dataset'] <- "Not in respective dataset"
df_spirals1[indices_set3,'Dataset'] <- "Not in respective dataset"
df_spirals1$Dataset[is.na(df_spirals1$Dataset)] <- "Not in respective dataset"

df_spirals2 <- data
df_spirals2[common_indices,'Dataset'] <- "In all datasets"
df_spirals2[indices_set1,'Dataset'] <- "Not in respective dataset"
df_spirals2[indices_set2,'Dataset'] <- "Only in respective dataset"
df_spirals2[indices_set3,'Dataset'] <- "Not in respective dataset"
df_spirals2$Dataset[is.na(df_spirals2$Dataset)] <- "Not in respective dataset"
#df_spirals1 <- df_spirals1[!(df_spirals1$Dataset=="Not in 1st dataset"),]
#df_spirals2 <- df_spirals2[!(df_spirals2$Dataset=="Not in 2nd dataset"),]

df_spirals3 <- data
df_spirals3[common_indices,'Dataset'] <- "In respective datasets"
df_spirals3[indices_set3,'Dataset'] <- "Only in respective dataset"
df_spirals3[indices_set2,'Dataset'] <- "Not in respective dataset"
df_spirals3[indices_set1,'Dataset'] <- "Not in respective dataset"
df_spirals3$Dataset[is.na(df_spirals3$Dataset)] <- "Not in respective dataset"

length(common_indices)/320

# LEARNERS RNDF ----------------------------------------------------------------
learners = lapply(num_trees,
                  function (i) {lrn("classif.ranger",
                                    num.trees = i,
                                    predict_type = "prob")})

learner = lrn("classif.rpart", predict_type = "prob")
# PLOT AND SAVE LEARNERS -------------------------------------------------------

pdf("../figure/cart_forest_overview_1.pdf", width = 12, height = 5.5)
GE1 <- round(calculateGE(task_train1, learner, test_data), 4)
plot1 <- plot_learner_prediction(learner, task_train1) +
  guides(shape = FALSE, alpha = FALSE) +
  scale_color_viridis_d() +
  scale_fill_viridis_d(end = .9)

GE2 <- round(calculateGE(task_train2, learner, test_data), 4)
plot2 <- plot_learner_prediction(learner, task_train2) +
  guides(shape = FALSE, alpha = FALSE) +
  scale_color_viridis_d() +
  scale_fill_viridis_d(end = .9)

GE3 <- round(calculateGE(task_train3, learner, test_data), 4)
plot3 <- plot_learner_prediction(learner, task_train3) +
  guides(shape = FALSE, alpha = FALSE) +
  scale_color_viridis_d() +
  scale_fill_viridis_d(end = .9)

(plot1 + labs(title = "Decision boundaries for dataset 1",
              subtitle = paste("Classification Error:", as.character(GE1), sep=" ")) +
    plot2  + labs(title = "Decision boundaries for dataset 2",
                  subtitle = paste("Classification Error:", as.character(GE2), sep=" ")) +
    plot3 + labs(title = "Decision boundaries for dataset 3",
                 subtitle = paste("Classification Error:", as.character(GE3), sep=" ")))
ggsave("../figure/cart_forest_overview_1.pdf", width = 12, height = 5.5)
dev.off()


pdf("../figure/cart_forest_overview_2.pdf", width = 8, height = 5.5)
learner_tmp <- lrn("classif.ranger", num.trees = 3, predict_type = "prob", mtry = 2)
GE3 <- round(calculateGE(task_spirals, learners[[2]], test_data), 4)
plot3 <- plot_learner_prediction(learner_tmp, task_spirals) +
  guides(shape = FALSE, alpha = FALSE) +
  scale_color_viridis_d() +
  scale_fill_viridis_d(end = .9)
plot3_print <- plot3 + labs(title = "Decision boundaries of combined learners",
                                         subtitle = paste("Classification Error:", as.character(GE3), sep=" "))
print(plot3_print)
ggsave("../figure/cart_forest_overview_2.pdf", width = 8, height = 5.5)
dev.off()

set.seed(123)
#pdf("../figure/cart_forest_overview_3.pdf", width = 8, height = 5.5)
#GE3 <- round(calculateGE(task_spirals, learners[[3]], test_data), 4)
#plot3 <- plot_learner_prediction(learners[[3]], task_spirals) +
#  guides(shape = FALSE, alpha = FALSE) +
#  scale_color_viridis_d() +
#  scale_fill_viridis_d(end = .9)
#print(plot3)
#ggsave("../figure/cart_forest_overview_3.pdf", width = 8, height = 5.5)
#dev.off()

pdf("../figure/cart_forest_overview_4.pdf", width = 8, height = 5.5)
GE4 <- round(calculateGE(task_spirals, learners[[3]], test_data), 4)
plot4 <- plot_learner_prediction(learners[[3]], task_spirals) +
  guides(shape = FALSE, alpha = FALSE) +
  scale_color_viridis_d() +
  scale_fill_viridis_d(end = .9)
print(plot4)
ggsave("../figure/cart_forest_overview_4.pdf", width = 8, height = 5.5)
dev.off()

pdf("../figure/cart_forest_overview_5.pdf", width = 8, height = 5.5)
GE5 <- round(calculateGE(task_spirals, learners[[4]], test_data), 4)
plot5 <- plot_learner_prediction(learners[[4]], task_spirals) +
  guides(shape = FALSE, alpha = FALSE) +
  scale_color_viridis_d() +
  scale_fill_viridis_d(end = .9)
print(plot5)
ggsave("../figure/cart_forest_overview_5.pdf", width = 8, height = 5.5)
dev.off()

pdf("../figure/cart_forest_overview_6.pdf", width = 8, height = 5.5)

plot1_1 <- plot1 + labs(caption = paste("Result of 1 learner; CE:", GE1, sep = " ")) + theme(plot.caption = element_text(hjust = 0))
plot3_1 <- plot3 + labs(caption = paste("Aggregated result of 3 learners; CE:", GE3, sep = " "))  + theme(plot.caption = element_text(hjust = 0))
plot4_1 <- plot4 + labs(caption = paste("Aggregated result of 10 learners; CE:", GE4, sep = " ")) + theme(plot.caption = element_text(hjust = 0))
plot5_1 <- plot5 + labs(caption = paste("Aggregated result of 100 learners; CE:", GE5, sep = " ")) +theme(plot.caption = element_text(hjust = 0))
grid.arrange(plot1_1, plot3_1, plot4_1, plot5_1, ncol = 2, nrow = 2)
ggsave("../figure/cart_forest_overview_6.pdf", width = 8, height = 5.5)
dev.off()

#pdf("../figure/cart_forest_overview_bs_datasets.pdf", width = 10, height = 5.5, onefile = TRUE)
#df_iris_tmp <- df_iris
plt_data1 <- ggplot() +
  geom_point(data = df_spirals1, mapping = aes(x = x, y = y, shape = Dataset, color = label)) +
  scale_color_viridis_d() + scale_fill_viridis_d(end = .9) + ggtitle("Bootstrap sample 1")+ theme(legend.position="none")
plt_data2 <- ggplot() +
  geom_point(data = df_spirals2, mapping = aes(x = x, y = y, shape = Dataset, color = label)) +
  scale_color_viridis_d() + scale_fill_viridis_d(end = .9) + ggtitle("Bootstrap sample 2")+ theme(legend.position="none")
plt_data3 <- ggplot() +
  geom_point(data = df_spirals3, mapping = aes(x = x, y = y, shape = Dataset, color = label)) +
  scale_color_viridis_d() + scale_fill_viridis_d(end = .9) + ggtitle("Bootstrap sample 3")+ theme(legend.position="none")
#print(plt_data1 + plt_data2 + plt_data3 + plot_layout(guides = "collect") & theme(legend.position = "bottom"))
ptemp <- ggarrange(plt_data1, plt_data2, plt_data3, ncol=3, common.legend = TRUE, legend="bottom")
print(ptemp)
ggsave("../figure/cart_forest_overview_bs_datasets.pdf", width = 10, height = 5.5)
dev.off()

#pdf("../figure/cart_forest_overview_oob_datasets.pdf", width = 8, height = 5.5)
#df_iris_tmp1 <- df_iris_tmp
#df_iris_tmp2 <- df_iris_tmp
#df_iris_tmp1[train_set1, "Datapoints"] <- "Bootstrapped datapoints"
#df_iris_tmp1[oob_indices1, "Datapoints"] <- "Data points used for OOB"

#df_iris_tmp2[train_set2, "Datapoints"] <- "Bootstrapped datapoints"
#df_iris_tmp2[oob_indices2, "Datapoints"] <- "Data points used for OOB"

#plot1 <- ggplot() +
#  geom_point(data = df_iris_tmp1, mapping = aes(x = Sepal.Length, y = Sepal.Width, color = Datapoints)) +
#  scale_color_viridis_d() + scale_fill_viridis_d(end = .9) + theme(legend.position="bottom")
#legend <- get_legend(plot1)
#plot2 <- ggplot() +
#  geom_point(data = df_iris_tmp2, mapping = aes(x = Sepal.Length, y = Sepal.Width, color = Datapoints)) +
#  scale_color_viridis_d() + scale_fill_viridis_d(end = .9) c
#plot1 +plot2 + plot_layout(guides = "collect") & theme(legend.position = "bottom")

#ggsave("../figure/cart_forest_overview_oob_datasets.pdf", width = 8, height = 5.5)
#dev.off()
