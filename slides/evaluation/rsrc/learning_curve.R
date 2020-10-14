# Create learning_curve.RData (used in resampling)

# PREREQ -----------------------------------------------------------------------

# nice report http://www.ritchieng.com/machinelearning-learning-curve/ and
# http://scikit-learn.org/stable/modules/learning_curve.html#learning-curve
# http://www.ritchieng.com/applying-machine-learning/

library(OpenML)
library(data.table)
library(parallelMap)
library(parallel)
library(mlr3)
library(mlr3learners)

setOMLConfig(server = "https://www.openml.org/api/v1", 
             apikey = "c1994bdb7ecb3c6f3c8f3b35f4b47f1f", 
             arff.reader = "farff")

# UTILITY FUNCTIONS ------------------------------------------------------------

# Perform subsampling with 'split' as split rate and 'iters' as number of 
# subsampling iterations

myLearningCurveSplit = function(learner, 
                                task, 
                                measure, 
                                iters = 100, 
                                split = 1) {
  
  # Stratify
  
  this_task = task$clone()
  this_task$col_roles$stratum = this_task$target_names
  
  # Apply with subsampling
  
  rdesc = rsmp("subsampling", repeats = iters, ratio = split)
  rdesc$instantiate(this_task)
  
  res = mlr3::resample(this_task, learner, rdesc)
  
  # Create measure that computes mean and standard deviation of mmce for both
  # train and test sets
  
  measure_custom = list(
    msr(measure, 
        id = "mean_test",  
        predict_sets = "test"),
    msr(measure, 
        id = "mean_train", 
        predict_sets = "train"),
    msr(measure, 
        id = "sd_test", 
        predict_sets = "test",
        aggregator = function(x) sd(x)),
    msr(measure, 
        id = "sd_train", 
        predict_sets = "train",
        aggregator = function(x) sd(x))
  )
  
  performance = res$aggregate(measure_custom)

  return(as.data.frame(c(percentage = split, as.list(performance))))
  
}

# Compute learning curve for many different split rates

myLearningCurve = function(learner, 
                           task, 
                           measure, 
                           iters = 100,
                           perc = seq(0.1, 0.9, by = 0.1)) {
  
  # Iterate over all training set percentages from 'perc'
  
  res = rbindlist(lapply(perc, function(x) {
    
    myLearningCurveSplit(learner = learner,
                         measure = measure, 
                         task = task, 
                         split = x, 
                         iters = iters)
  }
  
  ))
  
  # Make data frame
  
  melt(res, 
       id.vars = "percentage", 
       variable.name = "measure",
       value.name = c("mmce", "sd"), 
       measure = patterns("mean", "sd"))
  
}

# COMPUTATION FOR DIFFERENT LEARNERS -------------------------------------------

set.seed(123)

data = data.frame(getOMLDataSet(847))

task = TaskClassif$new(id = "wind", backend = data, target = "binaryClass")

learner_ranger = lrn("classif.ranger", 
                     num.threads = 1, 
                     num.trees = 10,
                     predict_sets = c("train", "test"))

learner_rpart  = lrn("classif.rpart", 
                     cp = 0.0025, 
                     predict_sets = c("train", "test"))

parallelStartSocket(20)
clusterSetRNGStream(iseed = 123)

res.ranger = myLearningCurve(learner = learner_ranger, 
                             measure = "classif.ce", 
                             task = task, 
                             iters = 100)

res.rpart = myLearningCurve(learner = learner_rpart, 
                            measure = "classif.ce", 
                            task = task, 
                            iters = 100)

res.rpart.small = myLearningCurve(learner = learner_rpart, 
                                  measure = "classif.ce", 
                                  task = task, 
                                  iters = 20)

parallelStop()

save(res.ranger, res.rpart, res.rpart.small, file = "learning_curve.RData")