 
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
lrn = makeLearner("regr.rpart", par.vals = list(minsplit = 5))
x = c(1,2,7,10,20)
y = c(1,1,0.5,10,11)
data = data.frame(x = x, y = y)
task = makeRegrTask("example task", data = data, target = "y")
mod = train(lrn, task)
# check the prediction and the SSE in each node
yval1 = mod$learner.model$frame$yval[2]
yval2 = mod$learner.model$frame$yval[3]
SSE1 = mod$learner.model$frame$dev[2]
SSE2 = mod$learner.model$frame$dev[3]

# create tree with x being log-transformed
x.log = log(x)
log.data = data.frame(x.log = x.log, y = y)
log.task = makeRegrTask("log task", data = log.data, target = "y")
log.mod = train(lrn, log.task)
# check predictions and SSE
yval1.log = log.mod$learner.model$frame$yval[2]
yval2.log = log.mod$learner.model$frame$yval[3]
SSE1.log = log.mod$learner.model$frame$dev[2]
SSE2.log = log.mod$learner.model$frame$dev[3]


set.seed(600000)
pdf("../figure/cart_splitcomp_1.pdf", width = 6, height = 4)
fancyRpartPlot(mod$learner.model, sub = "")
ggsave("../figure/cart_splitcomp_1.pdf", width = 6, height = 4)
dev.off()

