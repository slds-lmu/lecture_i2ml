
######################
#
#     CARTS and data dependency
#
#####################

library(mlbench)
library(dplyr)
library(rpart)
library(rattle)
library(mlr)
library(rpart.plot)
library(devtools)
library(BBmisc)
library(rpart.plot)
library(partykit)

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






################
#
#  Invariance of features
#
#############

trainlog = train1 %>% mutate_at(c("Pgain", "Vgain"), log)
head(trainlog, 3)
head(train1, 3)

model1 = rpart(Class ~., data = train1, minsplit = 30)
rattle::fancyRpartPlot(model1, palettes = "Oranges", main = "CART with normal data", sub = "")


modellog = rpart(Class ~., data = trainlog, minsplit = 30)
rattle::fancyRpartPlot(modellog, palettes = "Blues", main = "CART with logged data", sub = "")








#################
#
#   Random Forests and variable importance
#
###############


task = makeRegrTask(data = train1, target = "Class")
lrn1 = makeLearner("regr.randomForest")
mod = mlr::train(learner = lrn1, task = task)

varimp = getFeatureImportance(mod)
var = as.data.frame(t(varimp$res))
var$names = names(varimp$res)
p = ggplot(data = var, aes(x = names, y = V1)) + geom_bar(stat = "identity")
p



### partykit
library(partykit)

modForest = cforest(Class ~ Motor + Screw + Pgain + Vgain, data = train1)
var = as.data.frame(varimp(modForest))
var$names = rownames(var)
colnames(var) = c("varimp", "names")
p = ggplot(data = var, aes(x = names, y = varimp)) +
    geom_bar(stat = "identity") +
    ggtitle(label = "Variable Importance from partykit")
p

##########################
#
#     Proximity
#
##########################


library(randomForest)
library(mlbench)

# get data
spiral = mlbench::mlbench.spirals(500, cycles = 1, sd = 0.1)
p = ggplot(data = as.data.frame(spiral$x), aes(x = V1, y = V2, colour = spiral$classes)) +
  geom_point()
p

# fit forest and extract proximity measure
modProx = randomForest(x = spiral$x, y = spiral$classes, proximity = TRUE, oob.prox = TRUE)
proxMat = modProx$proximity
proxMat[1:5, 1:5]

# apply mds on the proximity matrix
mds = as.data.frame(cmdscale(proxMat))
mds$class = spiral$classes

# plot the result, sweet
p = ggplot(data = mds, aes(x = V1, y = V2, colour = class)) +
  geom_point() +
  labs(x = "1st dimension", y = "2nd dimension", title = "Multidimensional Scaling of Spiral data based on proximity")
p

















