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

task = tsk("iris")
task$select(c("Petal.Width", "Petal.Length"))

learner_1 = lrn("classif.lda", predict_type = "prob")
learner_2 = lrn("classif.qda", predict_type = "prob")


# PLOT 1 -----------------------------------------------------------------------

pdf("../figure/reg_class_dis_2.pdf", width = 8, height = 5)

plot_learner_prediction(learner_1, task) +
  scale_fill_viridis_d(end = .9) +
  guides(shape = FALSE, alpha = FALSE)

ggsave("../figure/reg_class_dis_2.pdf", width = 8, height = 5)
dev.off()

# PLOT 2 -----------------------------------------------------------------------

pdf("../figure/reg_class_dis_4.pdf", width = 8, height = 5)

plot_learner_prediction(learner_2, task) +
  scale_fill_viridis_d(end = .9) +
  guides(shape = FALSE, alpha = FALSE)

ggsave("../figure/reg_class_dis_4.pdf", width = 8, height = 5)
dev.off()