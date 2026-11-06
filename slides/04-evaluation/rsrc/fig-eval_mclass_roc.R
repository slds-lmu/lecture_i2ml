# PREREQ -----------------------------------------------------------------------

library(mlr3)
library(mlr3learners)

# BENCHMARK --------------------------------------------------------------------

task <- mlr3::tsk("german_credit")

learners <- c( 
  "classif.rpart", 
  "classif.ranger", 
  "classif.kknn",
  "classif.log_reg")

learners <- lapply(
  learners, lrn, predict_type = "prob", predict_sets = c("train", "test"))

resampling_strategy <- mlr3::rsmp("cv", folds = 3L)
design <- mlr3::benchmark_grid(task, learners, resampling_strategy)
bmr <- mlr3::benchmark(design)

measures <- list(
  mlr3::msr("classif.auc", id = "auc"),
  mlr3::msr("classif.recall", id = "tpr"),
  mlr3::msr("classif.specificity", id = "tnr"),
  mlr3::msr("classif.precision", id = "ppv"),
  mlr3::msr("classif.acc", id = "acc"),
  mlr3::msr("classif.fbeta", id = "f1"))

bm_result <- data.table::as.data.table(bmr$aggregate(measures))

bm_result[
  , sapply(measures, function(i) sprintf("rank_%s", i$id)) := lapply(
    .SD, 
    function(i) data.table::frank(1 - i)),
  .SDcols = sapply(measures, function(i) i$id)]

bm_metrics_long <- data.table::melt(
  bm_result, 
  id.vars = "learner_id", 
  measure.vars = sapply(measures, function(i) i$id))

bm_ranks_long <- data.table::melt(
  bm_result, 
  id.vars = "learner_id", 
  measure.vars = sapply(measures, function(i) sprintf("rank_%s", i$id)))

bm_result_long <- cbind(bm_metrics_long, rank = bm_ranks_long[, value])

data.table::setnames(bm_result_long, "variable", "metric")
bm_result_long[, metric := as.character(metric)]
data.table::setorder(bm_result_long, "metric")

bm_result_long[
  , plot_text := sprintf("%.0f (%.4f)", rank, value)]

# PLOT --------------------------------------------------------------------

p <- ggplot2::ggplot(
  bm_result_long, 
  aes(x = learner_id, y = metric, fill = rank)) +
  ggplot2::geom_tile() +
  ggplot2::geom_text(aes(label = plot_text), color = "white", size = 5L) +
  ggplot2::scale_fill_gradient(
    low = "darkgreen",
    high = "darkolivegreen3") +
  ggplot2::scale_x_discrete(
    labels = c("k-NN", "logistic regression", "random forest", "CART")) +
  ggplot2::scale_y_discrete(labels = toupper(unique(bm_result_long$metric))) +
  ggplot2::xlab("learner") +
  ggplot2::theme(
    text = element_text(size = 20L), 
    legend.position = "none")

ggplot2::ggsave(
  "../figure/eval_mclass_benchmark.pdf", p, height = 4L, width = 8L)
