 
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
pdf("../figure/cart_dis_1.pdf", width = 8, height = 5)
n = 100
data = data.frame(x1 = runif(n), x2 = runif(n))
data$y = as.factor(with(data, as.integer(x1 > x2)))
task = makeClassifTask(data = data, target = "y")
rpart = makeLearner("classif.rpart", cp = 0, minbucket = 2, maxdepth = 6)
pl = plotLearnerPrediction(rpart, task, gridsize = 300, cv = 0, err.mark = "none",
                           prob.alpha = FALSE)
pl = pl + geom_abline(slope = 1, linetype = 2)
print(pl)
ggsave("../figure/cart_dis_1.pdf", width = 8, height = 5)
dev.off()

