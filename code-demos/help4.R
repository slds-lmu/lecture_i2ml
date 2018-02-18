
######################
#
#     CARTS and data dependency
#
#####################


library(rpart)
library(rattle)

data("Servo")
# transform ordered factors to numeric
servo = Servo %>%
  mutate_at(c("Pgain", "Vgain"), as.character) %>%
  mutate_at(c("Pgain", "Vgain"), as.numeric)
str(servo)
rm(Servo)

# split in train and test with two different seeds to show data dependency
trainSize = 3/4

set.seed(1333)
trainIndices = sample(x = seq(1, nrow(servo), by = 1),
  size = ceiling(trainSize * nrow(servo)), replace = FALSE)
train1 = servo[ trainIndices, ]
test1 = servo[ -trainIndices, ]

set.seed(1)
trainIndices = sample(x = seq(1, nrow(servo), by = 1),
  size = ceiling(trainSize * nrow(servo)), replace = FALSE)
train2 = servo[ trainIndices, ]
test2 = servo[ -trainIndices, ]


model1 = rpart(Class ~., data = train1)
rattle::fancyRpartPlot(model1, palettes = "Oranges", sub = "CART from split 1")


model2 = rpart(Class ~., data = train2)
rattle::fancyRpartPlot(model2, palettes = "Blues", sub = "CART from split 2")

################
#
#     Understanding Hyperparameters
#
####################




task = makeRegrTask(data = train1, target = "Class")
lrn1 = makeLearner("regr.rpart")

plotParamSequence = function(learner, task, param, values, plotfun, ...) {
  for (v in values) {
    xs = list(...)
    xs[[param]] = v
    lrn2 = setHyperPars(learner, par.vals = xs)
    mod = mlr::train(lrn2, task)
    plotfun(mod$learner.model)
    title(sprintf("%s = %g", param, v))
    pause()
  }
}

plotParamSequenceRPart = function(...) plotParamSequence(learner = lrn1, plotfun = rpart.plot, ...)

minsplits = c(3, 10, 20, 40)
plotParamSequenceRPart(task = task, param = "minsplit", values = minsplits)
cps = c(0.001, 0.02, 0.1)
plotParamSequenceRPart(task = task, param = "cp", values = cps, minsplit = 5)







#################
#
#   Random Forests and variable importance
#
###############



