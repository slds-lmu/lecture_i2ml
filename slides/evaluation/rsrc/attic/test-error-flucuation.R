library(ggplot2)
library(mlr)
source("rsrc/plot_train_test.R")

my_ss = function(task) {
    lrn = makeLearner("classif.naiveBayes")
    r1 = subsample(lrn, task, iters = 50, show.info = FALSE)
    return(r1$measures.test[,2])
  }
  err1 = my_ss(iris.task)
  err2 = my_ss(sonar.task)
  d = rbind(
    data.frame(task = "iris", mce = err1),
    data.frame(task = "sonar", mce = err2)
  )
  pl = ggplot(d, aes(x = mce)) + geom_histogram()
  pl = pl + facet_wrap(vars(task), scales = "free")
  print(pl)

  ggsave("figure/test-error-flucuation.pdf", width = 8, height = 3.5)  
  