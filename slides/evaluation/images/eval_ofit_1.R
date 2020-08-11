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

library(plyr)
library(kernlab)
set.seed(600000)
pdf("eval_ofit_1.pdf", width = 8, height = 6)
data = as.data.frame(mlbench.2dnormals(n = 200, cl = 3))
data$classes = mapvalues(data$classes, "3", "1")
task = makeClassifTask(data = data, target = "classes")
learner = makeLearner("classif.ksvm")
plotLearnerPrediction(learner, task, kernel = "rbfdot", C = 1, sigma = 100, pointsize = 4)

ggsave("eval_ofit_1.pdf", width = 8, height = 6)
dev.off()

