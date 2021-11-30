# PREREQ -----------------------------------------------------------------------

library(data.table)
library(ggplot2)
library(mlr3)
library(mlr3learners)
library(mlr3viz)

# DATA -------------------------------------------------------------------------

dt_iris <- as.data.table(iris)[, .(Sepal.Width, Species)]

dt_1v1 <- list(
  iris_1 = dt_iris[Species == "setosa" | Species == "versicolor"],
  iris_2 = dt_iris[Species == "setosa" | Species == "virginica"],
  iris_3 = dt_iris[Species == "virginica" | Species == "versicolor"])

invisible(sapply(
  dt_1v1, 
  function(i) i[, Species := as.factor(as.character(Species))]))

tasks <- lapply(
  seq_along(dt_1v1), 
  function(i) {
    TaskClassif$new(
      sprintf("iris_%d", i), 
      backend = dt_1v1[[i]], 
      target = "Species")})

set.seed(1L)
train_sets <- sapply(dt_1v1, function(i) sample(i[, .I], 0.7 * nrow(i)))
test_sets <- sapply(
  seq_along(dt_1v1), 
  function(i) setdiff(dt_1v1[[i]][, .I], train_sets[, i]))

# MODELS -----------------------------------------------------------------------

learners <- lapply(
  seq_along(dt_1v1), 
  function(i) {
    assign(sprintf("l_%d", i), lrn("classif.lda", predict_type = "prob"))})

mapply(
  function(i, j) i$train(tasks[[j]], row_ids = train_sets[, j]), 
  learners, 
  seq_len(3L))

preds <- mapply(
  function(i, j) i$predict(tasks[[j]], row_ids = test_sets[, j]), 
  learners, 
  seq_along(tasks))

# PLOT -------------------------------------------------------------------------

titles <- c(
  "setosa vs versicolor", 
  "setosa vs virginica", 
  "versicolor vs virginica")

plots <- lapply(
  seq_along(preds),
  function(i) {
    mlr3viz::autoplot(preds[[i]], type = "roc") + 
      labs(x = "FPR", y = "TPR", title = titles[i])})

plot_grid <- gridExtra::grid.arrange(
  plots[[1]], plots[[2]], plots[[3]], nrow = 1L)

ggsave("../figure/eval_auc_extensions.pdf", plot_grid, width = 8L, height = 4L)
