# ------------------------------------------------------------------------------
# FIG: SHRINKAGE EFFECT ON CLASSIFICATION BOUNDARY
# ------------------------------------------------------------------------------

# Purpose: visualize effect of too much vs too little shrinkage

if (FALSE) remotes::install_github("mlr3learners/mlr3learners.gbm")
library(mlr3learners.gbm)
library(mlbench)
requireNamespace("gbm")

# DATA -------------------------------------------------------------------------

data <- mlbench::mlbench.spirals(n = 200L, sd = 0.3)
data_dt <- data.table::data.table(data$x, data$classes)
data.table::setnames(data_dt, c("x_1", "x_2", "class"))

task <- mlr3::TaskClassif$new("spirals", backend = data_dt, target = "class")

# TRAINING ---------------------------------------------------------------------

shrinkage_params <- c(0.0001, 0.8)

learners <- lapply(
  shrinkage_params,
  function(i, j) {
    mlr3::lrn(
      "classif.gbm", 
      distribution = "bernoulli",
      n.trees = 1000L,
      shrinkage = i,
      interaction.depth = 10L)})

# PLOTS ------------------------------------------------------------------------

plots <- lapply(
  seq_along(learners),
  function(i) {
    mlr3viz::plot_learner_prediction(learners[[i]], task) +
      ggplot2::xlab(expression(x[1])) +
      ggplot2::ylab(expression(x[2])) +
      ggplot2::ggtitle(
        sprintf("Boosting with shrinkage = %.4f", shrinkage_params[i])) +
      ggplot2::guides(shape = FALSE) +
      ggplot2::theme_minimal()})

ggplot2::ggsave(
  "../figure/gbm_regu_oversmoothing_overfitting.png",
  ggpubr::ggarrange(
    plots[[1]], 
    plots[[2]], 
    ncol = 2L, 
    common.legend = TRUE,
    legend = "right"),
  height = 3.5,
  width = 9L)
