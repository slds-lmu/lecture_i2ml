## COD Regression example
library(reshape)
library(mlr3verse)

set.seed(0)

cols <- c("crim", "zn", "indus", "chas", "nox", "rm", "age", "dis", "rad", "tax", "ptratio", "b", "lstat", "medv")
d <- tsk("boston_housing")$data()[, mget(cols)]
n <- nrow(d)

# creating 500 noise variables
p <- 500
x <- data.frame(replicate(p, rnorm(n)))
d <- cbind(d, x)
# task <- as_task_regr(d, target = "medv")

# creating subtasks for increasing sequence of subspaces of the feature space (p = 5, 7, 9, ...)
noise.feat.seq <- c(0, 100, 200, 300, 400, 500)
tasks <- lapply(noise.feat.seq, function(k) {
  # tt = subsetTask(task, features = 1:(12 + k))
  # tt$task.desc$id = sprintf("task%02i", k)
  # return(tt)
  task <- as_task_regr(d, target = "medv", id = sprintf("task%02i", k))
  task$select(task$feature_names[1:(12 + k)])
  task
})

# rdesc = makeResampleDesc("RepCV", folds = 10L, reps = 10L)
resamplings <- rsmps("repeated_cv", repeats = 10, folds = 10)

lrns <- lrns(c("regr.lm", "regr.rpart"))

design <- benchmark_grid(tasks = tasks, learners = lrns, resamplings = resamplings)
bmr <- benchmark(design)

measure <- msr("regr.mse")

res <- as.data.table(bmr$aggregate(measure))[, mean(regr.mse), by = c("learner_id", "task_id")]

names(res)[3] <- "mse.test.mean"
res <- res[order(learner_id), ]
res$d <- rep(seq(0, 500, by = 100), 2)

saveRDS(object = res, "datasets/lm_mse_dataset.rds")