 
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
pdf("../figure/cart_dis_2.pdf", width = 8, height = 5)
fn = function(x) (sin(4*x - 4)) * ((2*x - 2)^2) * (sin(20*x - 4))
d = data.frame(x = seq(0.2, 1, length.out = 7))
d$y = fn(d$x)
task = makeRegrTask(data = d, target = "y")
lrn = makeLearner("regr.rpart", minbucket = 1, minsplit = 1)
pl = plotLearnerPrediction(lrn, task, cv = 0)
x = seq(0.2, 1, length.out = 500)
dd = data.frame(x = x, y = fn(x))
pl = pl + geom_line(data = dd, aes(x, y, color = "red"))
pl = pl + theme(legend.position = "none")
print(pl)
ggsave("../figure/cart_dis_2.pdf", width = 8, height = 5)
dev.off()

