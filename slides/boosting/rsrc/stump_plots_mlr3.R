# ------------------------------------------------------------------------------
# FIG: BAGGING VS BOOSTING STUMPS
# ------------------------------------------------------------------------------

library(data.table)
library(ggplot2)
library(gridExtra)
library(mlbench)
library(mlr3verse)
library(paradox)
remotes::install_github("mlr3learners/mlr3learners.gbm")

# DATA -------------------------------------------------------------------------

data_1 <- mlbench::mlbench.spirals(n = 200L)
data_dt_1 <- data.table::data.table(data_1$x, data_1$classes)

set.seed(1L)
data_2 <- mlbench::mlbench.spirals(n = 200L, sd = 0.5)
data_dt_2 <- data.table::data.table(data_2$x, data_2$classes)

data <- list(data_dt_1, data_dt_2)

invisible(lapply(
  data, 
  function(i) data.table::setnames(i, c("x_1", "x_2", "class"))))

# TRAINING ---------------------------------------------------------------------

tasks <- lapply(
  data, 
  function(i) mlr3::TaskClassif$new("spirals", backend = i, target = "class"))

learners <- list(
  rf = mlr3::lrn("classif.ranger", max.depth = 1L),
  ada = mlr3learners.gbm::LearnerClassifGBM$new())

learners$ada$param_set$values <- list(
  distribution = "adaboost",
  interaction.depth = 1L)

search_spaces <- list(
  rf = paradox::ParamSet$new(list(
    paradox::ParamInt$new("num.trees", lower = 1L, upper = 1000L))),
  ada = paradox::ParamSet$new(list(
    paradox::ParamInt$new("n.trees", lower = 1L, upper = 1000L))))

resampling_strategy <- mlr3::rsmp("repeated_cv", folds = 5L, repeats = 5L)

n_trees <- c(1L, seq(100L, 1000L, by = 100L))

design_rf <- data.table::data.table(
  num.trees = n_trees)
design_ada <- data.table::data.table(
  n.trees = n_trees)

tuner_rf <- mlr3tuning::tnr("design_points", design = design_rf)
tuner_ada <- mlr3tuning::tnr("design_points", design = design_ada)

instances <- lapply(
  
  seq_along(data),
  
  function(i) {
    
    instances <- lapply(
      seq_along(learners),
      function(j) {
        mlr3tuning::TuningInstanceSingleCrit$new(
          task = tasks[[i]],
          learner = learners[[j]],
          resampling = resampling_strategy,
          measure = mlr3::msr("classif.ce"),
          search_space = search_spaces[[j]],
          terminator = mlr3tuning::trm("none"))})
    
    names(instances) <- c("rf", "ada")
    
    instances})

invisible(lapply(
  seq_along(data), 
  function(i) {
    tuner_rf$optimize(instances[[i]]$rf)
    tuner_ada$optimize(instances[[i]]$ada)}))

learners$rf$param_set$values$num.trees <- 1000L
learners$ada$param_set$values$n.trees <- 1000L

# PLOTS ------------------------------------------------------------------------

paths <- lapply(
  instances,
  function(i) {
    data.table::data.table(
      trees = i$rf$archive$data$num.trees,
      rf = i$rf$archive$data$classif.ce,
      ada = i$ada$archive$data$classif.ce)})

paths <- lapply(
  paths,
  function(i) {
    data.table::melt.data.table(
      i, 
      id = c("trees"), 
      measure = c("rf", "ada"))})

invisible(lapply(
  paths, 
  function(i) data.table::setnames(i, c("trees", "learner", "mmce"))))

p_1 <- lapply(
  paths,
  function(i) {
    ggplot2::ggplot(i, aes(x = trees, y = mmce, col = learner)) +
      ggplot2::theme_bw() +
      ggplot2::geom_line() +
      ggplot2::scale_color_viridis_d(end = 0.9) +
      ggplot2::theme(
        text = element_text(size = 15L), 
        axis.text.x = element_text(angle = 45L)) +
      ggplot2::scale_x_continuous(breaks = n_trees)})

p_2 <- lapply(
  tasks,
  function(i) {
    lapply(
      seq_along(learners),
      function(j) {
        mlr3viz::plot_learner_prediction(learners[[j]], i) +
          ggplot2::theme_bw() +
          ggplot2::ggtitle("") +
          ggplot2::xlab(expression(x[1])) +
          ggplot2::ylab(expression (x[2])) +
          ggplot2::theme(
            text = element_text(size = 15L),
            legend.title = element_blank()) +
          ggplot2::ggtitle(c("Random forest", "AdaBoost")[j]) +
          ggplot2::guides(shape = FALSE, alpha = FALSE)})})

p_3 <- 
  gridExtra::grid.arrange(p_1[[1]], p_2[[1]][[1]], p_2[[1]][[2]], nrow = 1L)
p_4 <- 
  gridExtra::grid.arrange(p_1[[2]], p_2[[2]][[1]], p_2[[2]][[2]], nrow = 1L)

ggplot2::ggsave(
  "../figure/stump_plots.png", p_3, height = 4L, width = 12L)
ggplot2::ggsave(
  "../figure/stump_plots_noisy.png", p_4, height = 4L, width = 12L)
