 
library(knitr)
library(mlbench)
library(mlr)
library(OpenML)

library(ggplot2)
library(viridis)
library(gridExtra)
library(ggrepel)
library(repr)

library(data.table)
library(BBmisc)


library(party)
library(kableExtra)
library(kknn)
library(e1071)

options(digits = 3, width = 65, str = strOptions(strict.width = "cut", vec.len = 3))


plot_lp = function(...){
  plotLearnerPrediction(...) + scale_fill_viridis_d()
}

set.seed(600000)


pdf("../figure/reg_class_knn_2.pdf", width = 9.5, height = 7)
f = function(k, leg) { 
  pl = plot_lp("classif.kknn", iris.task, cv = 0, k = k) +
    ggtitle(sprintf("k = %i", k))
  if (!leg)
    pl = pl + theme(legend.position = "none")
  return(pl)
}
grid.arrange(f(1, F), f(5, F), f(10, F), f(50, F))

ggsave("../figure/reg_class_knn_2.pdf", width = 9.5, height = 7)
dev.off()

