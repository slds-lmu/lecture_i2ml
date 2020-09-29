# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)
library(mlr3)
library(mlr3learners)
library(mlr3viz)
library(gridExtra)

# FUNCTIONS --------------------------------------------------------------------

plot_pred = function(k, legend = FALSE) {
  
  learner = lrn("classif.kknn", k = k, predict_type = "prob")
  
  pl = plot_learner_prediction(learner, task) +
    scale_fill_viridis_d(end = .9) +
    ggtitle(sprintf("k = %i", k))
  
  if (!legend) 
    pl = pl + theme(legend.position = "none")
  
  return(pl)
  
}

# DATA -------------------------------------------------------------------------

task = tsk("iris")
task$select(c("Sepal.Width", "Sepal.Length"))

# PLOT -------------------------------------------------------------------------

pdf("../figure/reg_class_knn_2.pdf", width = 9.5, height = 7)

grid.arrange(plot_pred(1), plot_pred(5), plot_pred(10), plot_pred(50))

ggsave("../figure/reg_class_knn_2.pdf", width = 9.5, height = 7)
dev.off()