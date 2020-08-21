 
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


pdf("../figure/reg_class_dis_4.pdf", width = 8, height = 5)

plotLearnerPrediction("classif.qda",
                      makeClassifTask(data = iris[,-(1:2)], target = "Species"),
                      cv = 0) +
  scale_fill_viridis_d()
ggsave("../figure/reg_class_dis_4.pdf", width = 8, height = 5)
dev.off()

