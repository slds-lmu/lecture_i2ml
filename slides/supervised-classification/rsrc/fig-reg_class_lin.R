# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)
library(mlr3)
library(mlr3learners)
library(mlr3viz)
library(tidyverse)

# DATA -------------------------------------------------------------------------

# Recode levels (otherwise, plot_learner_prediction will predict "setosa", too)

data = iris %>% 
  filter(Species != "setosa") %>% 
  mutate(Species = factor(ifelse(Species == "versicolor", 
                                 "versicolor", 
                                 "virginica")))

iris_sepal_bin = TaskClassif$new("iris_sepal_bin", 
                                 data, 
                                 target = "Species")

iris_sepal_bin$select(c("Sepal.Width", "Sepal.Length"))

learner_1 = lrn("classif.kknn", k = 25)
learner_2 = lrn("classif.log_reg")

# PLOT 1 -----------------------------------------------------------------------

pdf("../figure/reg_class_lin_1.pdf", width = 8.5, height = 6)

plot_learner_prediction(learner_1, iris_sepal_bin, grid_points = 400) +
  scale_fill_viridis_d(end = .9) +
  guides(shape = FALSE)

ggsave("../figure/reg_class_lin_1.pdf", width = 8.5, height = 6)
dev.off()

# PLOT 2 -----------------------------------------------------------------------

pdf("../figure/reg_class_lin_2.pdf", width = 8.5, height = 6)

plot_learner_prediction(learner_2, iris_sepal_bin, grid_points = 400) +
  scale_fill_viridis_d(end = .9) +
  guides(shape = FALSE)

ggsave("../figure/reg_class_lin_2.pdf", width = 8.5, height = 6)
dev.off()