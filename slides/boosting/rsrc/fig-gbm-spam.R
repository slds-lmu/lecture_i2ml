# ------------------------------------------------------------------------------
# FIG: EXAMPLE REGULARIZATION FOR SPAM DATA
# ------------------------------------------------------------------------------

# Purpose: visualize MCE for different shrinkage params with spam data

library(kernlab)
if (FALSE) remotes::install_github("mlr3learners/mlr3learners.gbm")
library(mlr3learners.gbm)
requireNamespace("gbm")

# DATA -------------------------------------------------------------------------

data(spam)
spam$type <- as.factor(spam$type)

task <- mlr3::TaskClassif$new("spam", backend = spam, target = "type")

# TRAINING ---------------------------------------------------------------------

n_trees <- 10000L
shrinkage_params <- c(0.001, 0.01, 0.1)
tree_depth_params <- c(1L, 3L, 5L, 20L)

learners <- lapply(
  shrinkage_params,
  function(i) {
    sapply(
      tree_depth_params,
      function(j) {
        mlr3::lrn(
          "classif.gbm",
          distribution = "bernoulli",
          n.trees = n_trees,
          cv.folds = 3L,
          shrinkage = i,
          interaction.depth = j)})})

for (i in unlist(learners)) i$train(task)

# PLOTS ------------------------------------------------------------------------

errors <- lapply(
  seq_along(shrinkage_params),
  function(i) {
    lapply(
      seq_along(tree_depth_params),
      function(j) learners[[i]][[j]]$model$cv.error)})

trajectories <- lapply(
  seq_along(errors),
  function(i) {
    lapply(
      seq_along(tree_depth_params),
      function(j) {
        data.table::data.table(
          shrinkage = shrinkage_params[[i]],
          tree_depth = tree_depth_params[[j]],
          trees = seq_len(n_trees),
          errors = errors[[i]][[j]])})})

trajectories_dt <- do.call(rbind, do.call(rbind, trajectories))
trajectories_dt$tree_depth <- as.factor(trajectories_dt$tree_depth)

saveRDS(trajectories_dt, "fig-gbm-spam-data.RDS")

p_1 <- ggplot2::ggplot(
  trajectories_dt,
  ggplot2::aes(x = trees, y = errors, col = tree_depth)) +
  ggplot2::geom_line() +
  ggplot2::theme_minimal() +
  ggplot2::ylim(c(0.1, 1.5)) +
  ggplot2::xlab("iterations") +
  ggplot2::ylab("mean classification error") +
  ggplot2::scale_color_viridis_d(end = 0.9, name = "tree depth") +
  ggplot2::facet_grid(cols = vars(shrinkage)) +
  ggplot2::ggtitle("shrinkage")

# load("gbm_spam_results.RData")

ggplot2::ggsave("../figure/gbm_spam.png", p_1, height = 3L, width = 8L)
