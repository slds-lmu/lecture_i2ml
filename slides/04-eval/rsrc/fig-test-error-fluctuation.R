# PREREQ -----------------------------------------------------------------------

library(ggplot2)
library(mlr3)
library(mlr3learners)
source("rsrc/plot_train_test.R")

# FUNCTIONS --------------------------------------------------------------------

my_ss = function(task) {
  
  learner = mlr3::lrn("classif.naive_bayes")
  resampling = mlr3::rsmp("subsampling", repeats = 50L)
  resample_result = mlr3::resample(task, learner, resampling)
  resample_result$score()$classif.ce
  
}

error_1 = my_ss(mlr3::tsk("iris"))
error_2 = my_ss(mlr3::tsk("sonar"))

data = rbind(
  data.frame(task = "iris", mce = error_1),
  data.frame(task = "sonar", mce = error_2))

# PLOT -------------------------------------------------------------------------

pl = ggplot(data, aes(x = mce)) + 
  geom_histogram(bins = 50L) + 
  facet_wrap(vars(task), scales = "free")

ggsave("../figure/test-error-flucuation.pdf", pl, width = 8, height = 3.5)  

# my_ss = function(task) {
#     lrn = makeLearner("classif.naiveBayes")
#     r1 = subsample(lrn, task, iters = 50, show.info = FALSE)
#     return(r1$measures.test[,2])
#   }
#   err1 = my_ss(iris.task)
#   err2 = my_ss(sonar.task)
#   d = rbind(
#     data.frame(task = "iris", mce = err1),
#     data.frame(task = "sonar", mce = err2)
#   )
#   pl = ggplot(d, aes(x = mce)) + geom_histogram()
#   pl = pl + facet_wrap(vars(task), scales = "free")
#   print(pl)
# 
#   ggsave("figure/test-error-flucuation.pdf", width = 8, height = 3.5)  
#   