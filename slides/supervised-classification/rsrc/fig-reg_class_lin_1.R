 
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


pdf("../figure/reg_class_lin_1.pdf", width = 8.5, height = 6)
iris_petal <- makeClassifTask(data = iris[,-(1:2)], target = "Species")
iris_sepal <- makeClassifTask(data = iris[,-(3:4)], target = "Species")
iris_sepal_bin <- makeClassifTask(data = subset(iris[,-(3:4)], Species != "setosa"),
                                  target = "Species")
# plotLearnerPrediction(makeLearner("classif.kknn"), iris_petal, cv=0, prob.alpha = FALSE, gridsize = 100)
# plotLearnerPrediction(makeLearner("classif.kknn"), iris_sepal, cv=0, prob.alpha = FALSE, gridsize = 100)
plotLearnerPrediction(makeLearner("classif.kknn", k = 25),
                      iris_sepal_bin, cv = 0, prob.alpha = FALSE, gridsize = 400) +
  scale_fill_viridis_d()
ggsave("../figure/reg_class_lin_1.pdf", width = 8.5, height = 6)
dev.off()

