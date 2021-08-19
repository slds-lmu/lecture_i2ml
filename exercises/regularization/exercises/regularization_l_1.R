library(mlr3)
library(mlr3learners)
library(mlr3viz)
library(ggplot2)

nsim = 1000L

x1 = runif(n = nsim, min = 0, max = 1)
x2 = runif(n = nsim, min = 2, max = 4)

y = 3 + 2 * x1 - 0.5 * x2 + rnorm(n = nsim, mean = 0, sd = 1)

df_sim = data.frame(y = y, x1 = x1, x2 = x2)

task = TaskRegr$new(id = paste("n_noise", 0), backend = df_sim, target = "y")

lm = lrn("regr.lm")
lm$id = "Linear Model"

ridge = lrn("regr.cv_glmnet", alpha = 0)
ridge$id = "Ridge"

lasso = lrn("regr.cv_glmnet", alpha = 1)
lasso$id = "Lasso"

lrns = list(lm, ridge, lasso)


design = benchmark_grid(task, lrns, rsmp("repeated_cv", repeats = 10, folds = 10))

res = benchmark(design)
autoplot(res)



nfeats = c(0, 5, 10, 50, 100, 200, 300, 400, 500)

df_res = data.frame(n_noise = numeric(0L), learner_id = character(0L), regr.mse = numeric(0L))

if (FALSE) {
  for (i in nfeats) {
    df_sim = data.frame(cbind(y = y, x1 = x1, x2 = x2, matrix(rnorm(nsim * i), nrow = nsim)))
    task = TaskRegr$new(id = paste("n_noise", i), backend = df_sim, target = "y")
    design = benchmark_grid(task, lrns, rsmp("repeated_cv", repeats = 10, folds = 10))
    res = benchmark(design)$aggregate()[, c("learner_id", "regr.mse")]
    res[, n_noise := i]
    df_res = rbind(df_res, res)
  }
}


ggplot(data = df_res, aes(x = n_noise, y = regr.mse, color = learner_id)) + geom_line() + geom_hline(yintercept = 1)

# With no noise features the linear model is best due to the real linear relationship.
# The restricted hypothesis space of the Lasso and Ridge Regression yields a slightly worse estimator since we are not as close to the real model due to the regularization.
# After adding noise features, the linear model has difficulties capturing the true relationship which explains the bias in the generalization error.
