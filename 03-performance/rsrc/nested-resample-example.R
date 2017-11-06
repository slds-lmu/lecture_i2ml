library(mlr)
library(mlbench)
library(plyr)
set.seed(123L)
configureMlr(show.learner.output = FALSE)

runTuningExperiment = function(n.train, n.test, n.big) {

  dset.train = as.data.frame(mlbench.friedman1(n.train, sd = 2))
  dset.test = as.data.frame(mlbench.friedman1(n.test, sd = 2))
  dset.testnew = as.data.frame(mlbench.friedman1(n.test, sd = 2))
  dset.big = as.data.frame(mlbench.friedman1(n.big, sd = 2))
  dset.joined = rbind(dset.train, dset.test)

  n.joined = n.train + n.test
  train.inds = 1:n.train 
  test.inds = setdiff(1:n.joined, train.inds)
  tsk = makeRegrTask("example.task", data = dset.joined, target = "y")

  # set up the base learners
  base.learners = list(
    makeLearner("regr.randomForest", par.vals = list(ntree = 10L)),
    makeLearner("regr.nnet")
  )

  # combine them in one for the tuning experiment
  lrn = makeModelMultiplexer(base.learners)

  # set up a param set to search over
  ps = makeModelMultiplexerParamSet(lrn,
    makeDiscreteParam("mtry", 1:5),
    makeDiscreteParam("size", 1:5)
  )

  # we'll use Holdout as resampling strategy
  rin = makeFixedHoldoutInstance(train.inds, test.inds, size = n.joined) 
  # and random search our tuning algorihm
  ctrl = makeTuneControlRandom(maxit = 50)
  # let's tune the params by combining all the above pieces 
  tr = tuneParams(lrn, tsk, rin, par.set = ps, control = ctrl, show.info = TRUE)
  perf.biased = tr$y
  # eval tuned model on real large test set
  lrn.opt = setHyperPars(lrn, par.vals = tr$x)
  m = train(lrn.opt, tsk, subset = train.inds)
  p = predict(m, newdata = dset.testnew)
  perf.nested = performance(p)
  p = predict(m, newdata = dset.big)
  perf.real = performance(p)
  
  data.frame(value = c(perf.biased, perf.nested, perf.real),
    type = factor(c("biased ", "nested", "real")))
}


res.df = sapply(1:50, function(x) {
  runTuningExperiment(100, 100L, 50000L)
}, simplify = FALSE)

res.df = do.call("rbind", res.df)

save2(file = "nested-resample-example.RData", res.df)
