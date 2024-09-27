# PREREQ -----------------------------------------------------------------------

library(knitr)
library(mlr3)
library(mlr3learners)
library(mlr3viz)
library(ggplot2)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# DATA -------------------------------------------------------------------------

set.seed(600000)

task = tsk("iris")
task$select(c("Sepal.Width", "Sepal.Length"))

num_trees = c(1, 10, 500)

learners = lapply(num_trees, 
                  function (i) {lrn("classif.ranger",
                                    num.trees = i, 
                                    predict_type = "prob")}) 

# PLOT 1 -----------------------------------------------------------------------

pdf("../figure/cart_forest_intro_1.pdf", width = 8, height = 5.5)

plot_learner_prediction(learners[[1]], task) +
  ggtitle(paste0(num_trees[1], " Tree(s) for Iris Dataset")) +
  guides(shape = FALSE, alpha = FALSE)

ggsave("../figure/cart_forest_intro_1.pdf", width = 8, height = 5.5)
dev.off()

# PLOT 2 -----------------------------------------------------------------------

pdf("../figure/cart_forest_intro_2.pdf", width = 8, height = 5.5)

plot_learner_prediction(learners[[2]], task) +
  ggtitle(paste0(num_trees[2], " Tree(s) for Iris Dataset")) +
  guides(shape = FALSE, alpha = FALSE)

ggsave("../figure/cart_forest_intro_2.pdf", width = 8, height = 5.5)
dev.off()

# PLOT 3 -----------------------------------------------------------------------

pdf("../figure/cart_forest_intro_3.pdf", width = 8, height = 5.5)

plot_learner_prediction(learners[[3]], task) +
  ggtitle(paste0(num_trees[3], " Tree(s) for Iris Dataset")) +
  guides(shape = FALSE, alpha = FALSE)

ggsave("../figure/cart_forest_intro_3.pdf", width = 8, height = 5.5)
dev.off()