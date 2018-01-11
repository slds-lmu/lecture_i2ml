# general stuff
library(methods)
library(devtools)
library(BBmisc)
library(RWeka)
# visuakization of trees
library(rpart.plot)
library(partykit)
# install recent version of mlr
# install_github("mlr", username = "berndbischl")
library(mlr)


### load data, peak into, remove smaller classes and arrive at task
data = read.arff("lymphography.dat")
print(summary(data))

data = subset(data, Class %in% c("metastases", "malign_lymph"))
data = droplevels(data)
print(summary(data))
task = makeClassifTask(data = data, target = "Class")

### the tree models we want to compare
lrn1 = makeLearner("classif.rpart")
lrn2 = makeLearner("classif.J48")

### resample learners and store models
# the data set is pretty small, n is about 150
# so if we really want to compare via CV
# a repeated CV might be in order here
rdesc = makeResampleDesc("RepCV", folds = 10L, reps = 10L)
rin = makeResampleInstance(rdesc, task = task)

r1 = resample(lrn1, task, rin, model = TRUE)
r2 = resample(lrn2, task, rin, model = TRUE)

print(r1$aggr)
print(r2$aggr)


### visualize some models on some splits
# we see they are pretty different.
# J48 is different from CART
# but we also see the "instability" of the tree learners themselves

# (side note: plotting both J48 and CART next to each other on one screen was harder than I expected ...
# one discovers great things in R everyday)
X11(); X11();

devs = dev.list()

for (i in 1:10) {
  m1 = r1$models[[i]]$learner.model
  m2 = r2$models[[i]]$learner.model
  dev.set(devs[1L])
  rpart.plot(m1, extra = 4L)
  dev.set(devs[2])
  plot(m2)
  pause()
}

dev.off(); dev.off()


### complexity control

# helpers to fit with different param values and visualize
plotParamSequence = function(learner, task, param, values, plotfun, ...) {
  for (v in values) {
    xs = list(...)
    xs[[param]] = v
    lrn2= setHyperPars(learner, par.vals = xs)
    mod = train(lrn2, task)
    plotfun(mod$learner.model)
    title(sprintf("%s = %g", param, v))
    pause()
  }
}

plotParamSequenceRPart = function(...)
  plotParamSequence(learner = lrn1, plotfun = rpart.plot, ...)

plotParamSequenceJ48 = function(...)
  plotParamSequence(learner = lrn2, plotfun = plot, ...)

### complexity control CART / rpart

minsplits = c(3, 10, 20)
plotParamSequenceRPart(task = task, param = "minsplit", values = minsplits)
cps = c(0.001, 0.02, 0.1)
plotParamSequenceRPart(task = task, param = "cp", values = cps, minsplit = 1)

# we could also call rpart::prune or do other stuff....

### complexity control for C4.5 / J48

# understand control params
print(WOW("J48"))
Ms = c(5, 20)
plotParamSequenceJ48(task = task, param = "M", values = Ms)
Cs = c(0.25, 0.05)
plotParamSequenceJ48(task = task, param = "C", values = Cs)

# again we could look other params as well here

### model comparison:

# we already did that above with a 10x10 CV for models with defaults
# CART was a bit better in that case
# we will not do a proper model selection now here, tuning every single paramter...
