# Create overtuning-example.RData (used in nested-resampling)

library(BBmisc)
library(mlr3)
library(ggplot2)
library(reshape2)

simulate_task = function(task_size, cv_iters, tune_iters) {
  
  # Simulates stupid task of given size with 0,1 labels with equal prob
   
  make_my_task = function(n) {
    
    y = sample(c(0, 1), size = n, replace = TRUE)
    d = data.frame(x = 1, y = as.factor(y))
    TaskClassif$new(id = "simulation", backend = d, target = "y")
    
  }
  
  task = make_my_task(task_size)
  
  # "Tuning" featureless learner by resampling it very often
  
  learner = lrn("classif.featureless", method = "weighted.sample")
  resampling = rsmp("cv", folds = cv_iters)
  
  replicate(tune_iters, 
            mlr3::resample(task,
                           learner,
                           resampling,
                           store_models = TRUE
                           )$aggregate(msr("classif.ce")))
  
}

set.seed(123)
tune_iters = 100L
cv_iters = 2L
task_sizes = c(100, 200, 500)
reps = 50

res1 = array(dim = c(length(task_sizes), tune_iters, reps), 
             dimnames = list(task_size = task_sizes, 
                             iter = 1:tune_iters, 
                             rep = 1:reps))

res2 = res1

for (j in 1:reps) { 
  
  for (i in seq_along(task_sizes)) {
    
    task_size = task_sizes[i]
    messagef("rep=%i; task size=%i", j, task_size)
    v = simulate_task(task_size, cv_iters = cv_iters, tune_iters = tune_iters)  
    res1[i, , j] = v
    res2[i, , j] = cummin(v)
    
  }
  
}

res2_mean = apply(res2, 1:2, mean)

save2(file = "overtuning-example.RData", 
      res1 = res1, 
      res2 = res2, 
      res2.mean = res2_mean)
