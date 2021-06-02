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
# trajectories_dt <- readRDS("fig-gbm-spam-data.RDS")

plots <- lapply(
  shrinkage_params,
  function(i) {
    ggplot2::ggplot(
      trajectories_dt[shrinkage == i],
      ggplot2::aes(x = trees, y = errors, col = tree_depth)) +
      ggplot2::geom_line() +
      ggplot2::theme_minimal() +
      ggplot2::ylim(c(0.1, 1.5)) +
      ggplot2::xlab("iterations") +
      ggplot2::ylab("mean classification error") +
      ggplot2::scale_color_viridis_d(end = 0.9, name = "tree depth") +
      ggplot2::ggtitle(sprintf("shrinkage = %.3f", i))})

idx_best <- which.min(trajectories_dt$errors)
trajectories_dt[idx_best]

plots[[1]] <- plots[[1]] +
  ggplot2::geom_segment(
    x = 1000L,
    xend = 2500L,
    y = 0.1,
    yend = 0.3,
    color = "red",
    arrow = ggplot2::arrow(length = ggplot2::unit(0.03, "npc"))) +
  ggplot2::geom_point(
    ggplot2::aes(
      x = trajectories_dt[idx_best, trees],
      y = trajectories_dt[idx_best, errors]),
    size = 1.1,
    color = "red")

ggplot2::ggsave(
  "../figure/gbm_spam.png",
  ggpubr::ggarrange(
    plots[[1]], 
    plots[[2]],
    plots[[3]],
    ncol = 3L, 
    common.legend = TRUE,
    legend = "right"),
  height = 3L,
  width = 9L)
