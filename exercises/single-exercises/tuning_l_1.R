# Complex hyperparameter tuning with wrapper and nested resampling
library(mlr)
library(mlbench)
data(Ionosphere)
# task = makeClassifTask(data = Ionosphere[, -(1:2)], target = "Class")
task = makeClassifTask(data = Ionosphere[, -c(2)], target = "Class")

# param set for an svm, multiple kernel, dependent parameters and trafos

# upon student request, I show someting even more complicated.
# we also add a feature filter to the SVM (covered later in lecture)
# and tune the number of selected features JOINTLY with the SVM. nice!

# lrn = makeFilterWrapper(makeLearner("classif.svm"), fw.method = "information.gain")
lrn = makeLearner("classif.svm")

ps = makeParamSet(
  # makeNumericParam("fw.perc", lower = 0.1, upper = 1),
  makeDiscreteParam("kernel", values = c("polynomial", "radial")),
  makeNumericParam("cost", lower = -15, upper = 15, trafo = function(x) 2^x),
  makeNumericParam("gamma", lower = -15, upper = 15, trafo = function(x) 2^x,
    requires = quote(kernel == "radial")),
  makeIntegerParam("degree", lower = 1, upper = 5,
    requires = quote(kernel == "polynomial"))
)

# we can use irace or a simple random search here
# ctrl = makeTuneControlIrace(maxExperiments = 200L)
ctrl = makeTuneControlRandom(maxit = 20)

# this adds the tuning to the learner, we use holdout on inner resampling
inner = makeResampleDesc(method = "Holdout")
lrn2 = makeTuneWrapper(lrn, inner, par.set = ps, control = ctrl, measures = mmce)

# now run everything, we use CV with 2 folds on the outer loop
outer = makeResampleDesc(method = "CV", iters = 2)
r = resample(lrn2, task, outer, extract = getTuneResult)
print(r)

# lets look at some results from the outer iterations
r$extract[[1]]$x
r$extract[[1]]$y
r$extract[[1]]$opt.path

