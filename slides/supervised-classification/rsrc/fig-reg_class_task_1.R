# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)
library(mlr3)
library(mlr3learners)
library(mlr3viz)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# DATA -------------------------------------------------------------------------

set.seed(123)

task_1 = tsk("sonar")
task_1$select(c("V1", "V2"))
learner_1 = lrn("classif.log_reg", predict_type = "prob")

task_2 = tsk("iris")
task_2$select(c("Petal.Length", "Petal.Width"))
learner_2 = lrn("classif.svm", predict_type = "prob")

# PLOT 1 -----------------------------------------------------------------------

pdf("../figure/reg_class_task_1.pdf", width = 6, height = 6)

plot_learner_prediction(learner_1, task_1) + 
  scale_fill_viridis_d(end = .9) +
  guides(shape = FALSE, alpha = FALSE) +
  xlim(0, 0.05) + 
  ggtitle("Sonar")

ggsave("../figure/reg_class_task_1.pdf", width = 6, height = 6)
dev.off()

# PLOT 2 -----------------------------------------------------------------------

pdf("../figure/reg_class_task_2.pdf", width = 6, height = 6)

plot_learner_prediction(learner_2, task_2) + 
  scale_fill_viridis_d(end = .9) +
  guides(shape = FALSE, alpha = FALSE) +
  ggtitle("Iris")

ggsave("../figure/reg_class_task_2.pdf", width = 6, height = 6)
dev.off()