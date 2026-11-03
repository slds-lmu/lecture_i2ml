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
colnames(data) <- c("x.1", "x.2", "Y")
data$Y <- as.numeric(data$Y)
data[data$Y == 2,3] <- 0
data$Y <- as.factor(data$Y)

binary_task = TaskClassif$new("data_binary", data, target = "Y")
binary_task$select(c("x.1", "x.2"))

# FUNCTIONS --------------------------------------------------------------------
legend_title <- "Class"

ff_legend = function(type, title, ...) {
  
  learner = lrn(type, predict_type = "prob")
  
  pl = plot_learner_prediction(learner, binary_task)
  pl = pl + 
    scale_fill_hue() +
    ggtitle(title) +
    xlim(-3, 3) + 
    ylim(-3, 4) +
    guides(shape = FALSE, alpha = FALSE) +
    theme(axis.text=element_text(size=14),title=element_text(size = 16), axis.title=element_text(size=14), 
          legend.key.size = unit(1.5, 'cm'), legend.title = element_text(size=14),
          legend.text = element_text(size=14), legend.title.align=0.3)
  
}


# PLOT -------------------------------------------------------------------------

combined_plot <-  ff_legend("classif.log_reg", "Logistic Regression \n (Discriminant Approach)") + ff_legend("classif.naive_bayes", "Naive Bayes \n (Generative Approach)") +
  plot_layout(guides = "collect") 

ggsave("figure/nutshell_classif_binary_task.png", plot = combined_plot, width = 8, height = 4)

