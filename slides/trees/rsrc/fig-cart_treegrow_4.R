 
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


set.seed(123)
pdf("../figure/cart_treegrow_4.pdf", width = 8, height = 4)
task = subsetTask(iris.task, seq(1, 150, by = 20))
lrn = makeLearner("classif.rpart", cp = 0, minbucket = 1, maxdepth = 1)
pl = plotLearnerPrediction(lrn, task, gridsize = 100,
                           cv = 0, prob.alpha = FALSE, err.mark = "none")
pl = pl + theme(legend.position="none")
print(pl)

ggsave("../figure/cart_treegrow_4.pdf", width = 8, height = 4)
dev.off()

