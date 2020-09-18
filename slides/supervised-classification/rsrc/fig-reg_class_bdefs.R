
library(knitr)
library(mlbench)
library(mlr)
library(OpenML)

library(ggplot2)
library(viridis)
library(gridExtra)
library(ggrepel)
library(repr)
library(MASS)
library(data.table)
library(BBmisc)

library(party)
library(kableExtra)
library(kknn)
library(e1071)
library(car)

options(digits = 3, width = 65, str = strOptions(strict.width = "cut", vec.len = 3))

plot_lp = function(...){
  plotLearnerPrediction(...) + scale_fill_viridis_d()
}


pdf("../figure/reg_class_bdefs.pdf", width = 8, height = 5.5)

task = sonar.task

ff = function(a, b, ...) {
  feats = c("V1", "V2")
  pl = plot_lp(makeLearner(a, ...), task = task, features = feats, cv = 0) 
  pl = pl + ggtitle(b) + xlim(0, 0.05) + ylim(0, 0.1)
}

grid.arrange(ncol = 2, nrow = 2,
             ff("classif.logreg", "Log. Regr."),
             ff("classif.naiveBayes", "Naive Bayes"),
             ff("classif.rpart", "CART Tree"),
             ff("classif.ksvm", "SVM", sigma = 0.001))

ggsave("../figure/reg_class_bdefs.pdf", width = 8, height = 5.5)
dev.off()

