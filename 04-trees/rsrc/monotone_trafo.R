# Shows that linear transformation of independent variables
# do not change the SSE, nor the structure of the tree
# Two trees as pngs will be saved such that it can be modified
# with a image editing software
library(mlr)
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

# Create plots
library(rattle)
png("figure_man/monotone_trafo1.png")
fancyRpartPlot(mod$learner.model, sub = "")
dev.off()
png("figure_man/monotone_trafo2.png")
fancyRpartPlot(log.mod$learner.model, sub = "")
dev.off()
