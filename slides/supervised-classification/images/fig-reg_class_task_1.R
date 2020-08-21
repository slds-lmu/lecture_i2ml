setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
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


pdf("reg_class_task_1.pdf", width = 6, height = 6)
plot_lp(makeLearner("classif.logreg"), sonar.task) + xlim(0,0.05) + ggtitle("Sonar")
ggsave("reg_class_task_1.pdf", width = 6, height = 6)
dev.off()

