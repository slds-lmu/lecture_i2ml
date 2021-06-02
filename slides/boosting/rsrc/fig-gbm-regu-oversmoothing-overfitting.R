# ------------------------------------------------------------------------------
# FIG: SHRINKAGE EFFECT ON CLASSIFICATION BOUNDARY
# ------------------------------------------------------------------------------

# Purpose: visualize effect of too much vs too little shrinkage

if (FALSE) remotes::install_github("mlr3learners/mlr3learners.gbm")
library(mlr3)
library(mlr3learners.gbm)
library(mlbench)
requireNamespace("gbm")

# DATA -------------------------------------------------------------------------

set.seed(1L)
data <- mlbench::mlbench.spirals(n = 300L, cycles = 1.5, sd = 0.1)
data_dt <- data.table::data.table(data$x, data$classes)
data.table::setnames(data_dt, c("x_1", "x_2", "class"))

task <- mlr3::TaskClassif$new("spirals", backend = data_dt, target = "class")

# TRAINING ---------------------------------------------------------------------

shrinkage_params <- c(1e-5, 0.001, 0.8)

learners <- lapply(
  shrinkage_params,
  function(i, j) {
    mlr3::lrn(
      "classif.gbm", 
      distribution = "bernoulli",
      n.trees = 10000L,
      shrinkage = i,
      interaction.depth = 10L)})

# PLOTS ------------------------------------------------------------------------

plots <- lapply(
  seq_along(learners),
  function(i) {
    mlr3viz::plot_learner_prediction(learners[[i]], task) +
      ggplot2::xlab(expression(x[1])) +
      ggplot2::ylab(expression(x[2])) +
      ggplot2::scale_fill_viridis_d(end = 0.9) +
      ggplot2::ggtitle(
        sprintf(
          "shrinkage = %s", 
          c("0.00001", "0.001", "0.8")[i])) +
      ggplot2::guides(shape = FALSE) +
      ggplot2::theme_minimal()})

ggplot2::ggsave(
  "../figure/gbm_regu_oversmoothing_overfitting.png",
  ggpubr::ggarrange(
    plots[[1]], 
    plots[[2]],
    plots[[3]],
    ncol = 3L, 
    common.legend = TRUE,
    legend = "right"),
  height = 3L,
  width = 9L)
