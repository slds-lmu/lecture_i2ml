# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)
library(mlr3)
library(mlr3learners)
library(mlr3viz)
library(gridExtra)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# DATA -------------------------------------------------------------------------

task = tsk("sonar")
task$select(c("V1", "V2"))

# FUNCTIONS --------------------------------------------------------------------

ff = function(type, title, ...) {
  
  learner = lrn(type, predict_type = "prob")
  
  pl = plot_learner_prediction(learner, task)
  pl = pl + 
    scale_fill_viridis_d(end = .9) +
    ggtitle(title) + 
    xlim(0, 0.05) + 
    ylim(0, 0.1) +
    guides(shape = FALSE, alpha = FALSE)
  
}

# PLOT -------------------------------------------------------------------------

pdf("../figure/reg_class_bdefs.pdf", width = 8, height = 5.5)

grid.arrange(ncol = 2, 
             nrow = 2,
             ff("classif.log_reg", "Log. Regr."),
             ff("classif.naive_bayes", "Naive Bayes"),
             ff("classif.rpart", "CART Tree"),
             ff("classif.svm", "SVM", sigma = 0.001))

ggsave("../figure/reg_class_bdefs.pdf", width = 8, height = 5.5)
dev.off()