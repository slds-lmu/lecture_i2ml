library(mlr)
library(mlbench)
library(data.table)

n = 500
dims = c(1, seq(100, 500, by = 100))
k1 = 3
k2 = 7
k3 = 15

## Classification Example

# Simulate some data of ML for growing dimenstionality
getData = function(d, n) {
  mlb = mlbench.twonorm(n = n, d = d) # one data set that i found where bayeserr seems to stay fixed...
  data = as.data.frame(mlb)
  task = makeClassifTask(data = data, target = "classes")
  task$task.desc$id = toString(d)
  # get bayeserror to make sure that stays the same
  # do that on large data set, so we get small estim error
  mlb2 = mlbench.twonorm(n = 100000, d = d)
  task$bayeserr = mean(mlb2$classes != bayesclass(mlb2))
  return(task)
}

tasks = lapply(dims, function(d) {
  task = getData(n = n, d = d)
})

bayeserrs = extractSubList(tasks, "bayeserr")

rdesc = makeResampleDesc("RepCV", folds = 10L, reps = 10L)

lrns = list(makeLearner("classif.kknn", id = paste(k1, "-NN", sep = ""), k = k1),
            makeLearner("classif.kknn", id = paste(k2, "-NN", sep = ""), k = k2),
            makeLearner("classif.kknn", id = paste(k3, "-NN", sep = ""), k = k3))


bres = benchmark(lrns, tasks, resamplings = rdesc, show.info = TRUE)

res = as.data.table(bres)[, mean(mmce), by = c("learner.id", "task.id")]
res = rbind(res, data.frame(learner.id = "Bayes Optimal Classifier", task.id = unique(res$task.id), V1 = bayeserrs))
names(res) = c("learner", "d", "mmce.test.mean")

# some transforming 
res = res[order(res$d), ]
res$d = rep(c(1, seq(100, 500, by = 100)), each = 4)

saveRDS(object = res, "code/cod_knn.rds")