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
library(rpart)
library(rpart.plot)
library(randomForest)
library(rattle)
library(smoof)
library(kableExtra)
library(kknn)
library(e1071)
library(rattle)

library(plyr)
library(kernlab)

options(digits = 3, width = 65, str = strOptions(strict.width = "cut", vec.len = 3))


scale_c_d <- scale_colour_discrete <- scale_color_discrete <-
  function(...) {
    viridis::scale_color_viridis(..., end = .9, discrete = TRUE, drop = TRUE)
  }


set.seed(600000)
pdf("cart_forest_intro_2.pdf", width = 8, height = 5.5)
plotLearnerPrediction("classif.randomForest", iris.task, cv = 0, ntree = 10) + 
  ggtitle("10 Trees for Iris Dataset")
ggsave("cart_forest_intro_2.pdf", width = 8, height = 5.5)
dev.off()

