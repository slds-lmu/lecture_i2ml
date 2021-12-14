library(mlr3verse)
library(kknn)
library(mlbench)
library(data.table)
library(BBmisc)

set.seed(0)

n <- 500
dims <- c(1, seq(100, 500, by = 100))
k1 <- 3
k2 <- 7
k3 <- 15

## Classification Example

# Simulate some data of ML for growing dimenstionality
getData <- function(d, n) {
  mlb <- mlbench.twonorm(n = n, d = d) # one data set that i found where bayeserr seems to stay fixed...
  data <- as.data.frame(mlb)
  as_task_classif(data, target = "classes", id = toString(d))
  # task$task.desc$id <- toString(d)
  # get bayeserror to make sure that stays the same
  # do that on large data set, so we get small estim error

}

make_knn_learner <- function(k) {
  learner <- lrn("classif.kknn", id = paste0(k, "-NN"))
  learner$param_set$values <- list(k = k)
  learner
}

tasks <- lapply(dims, function(d) {
  getData(n = n, d = d)
})
bayeserrs <- lapply(dims, function(d) {
  mlb2 <- mlbench.twonorm(n = 100000, d = d)
  bayeserr <- mean(mlb2$classes != bayesclass(mlb2))
  bayeserr
})
# bayeserrs <- extractSubList(tasks, "bayeserr")

resamplings <- rsmps("repeated_cv", repeats = 10, folds = 10)
# rdesc <- makeResampleDesc("RepCV", folds = 10L, reps = 10L)

# lrns = list(lrn("classif.kknn", id = paste(k1, "-NN", sep = ""), k = k1),
#             makeLearner("classif.kknn", id = paste(k2, "-NN", sep = ""), k = k2),
#             makeLearner("classif.kknn", id = paste(k3, "-NN", sep = ""), k = k3))

lrns <- lapply(c(k1, k2, k3), make_knn_learner)
# bres = benchmark(lrns, tasks, resamplings = rdesc, show.info = TRUE)
design <- benchmark_grid(tasks = tasks, learners = lrns, resamplings = resamplings)
bmr <- benchmark(design)

measure <- msr("classif.ce")

# res = as.data.table(bres)[, mean(mmce), by = c("learner.id", "task.id")]
# res = rbind(res, data.frame(learner.id = "Bayes Optimal Classifier", task.id = unique(res$task.id), V1 = bayeserrs))
# names(res) = c("learner", "d", "mmce.test.mean")
res <- as.data.table(bmr$aggregate(measure))[, mean(classif.ce), by = c("learner_id", "task_id")]
res <- rbind(res, data.frame(learner_id = "Bayes Optimal Classifier", task_id = unique(res$task_id), V1 = unlist(bayeserrs)))
names(res) <- c("learner", "d", "mmce.test.mean")
# some transforming 
res <- res[order(res$d), ]
res$d <- rep(c(1, seq(100, 500, by = 100)), each = 4)

saveRDS(object = res, "datasets/knn_misclassification_dataset.rds")