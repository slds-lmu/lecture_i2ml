# PREREQ -----------------------------------------------------------------------

library(mlr3)
library(mlr3learners)

# BENCHMARK --------------------------------------------------------------------

task <- tsk("german_credit")

learners <- c( 
  "classif.rpart", 
  "classif.ranger", 
  "classif.kknn",
  "classif.log_reg")

learners <- lapply(
  learners, lrn, predict_type = "prob", predict_sets = c("train", "test"))

resampling_strategy <- rsmp("cv", folds = 3L)
design <- benchmark_grid(task, learners, resampling_strategy)
bmr <- benchmark(design)

measures <- list(
  msr("classif.auc", id = "auc"),
  msr("classif.recall", id = "recall"),
  msr("classif.specificity", id = "specificity"),
  msr("classif.precision", id = "precision"),
  msr("classif.acc", id = "accuracy"),
  msr("classif.fbeta", id = "f1"))

bm_result <- as.data.table(bmr$aggregate(measures))

# scale_zero_one <- function(x) (x - min(x)) / (max(x) - min(x))
# 
# bm_result[
#   , sapply(measures, function(i) i$id) := lapply(.SD, scale_zero_one),
#   .SDcols = sapply(measures, function(i) i$id)]

bm_result[
  , sapply(measures, function(i) i$id) := lapply(.SD, function(i) frank(1 - i)),
  .SDcols = sapply(measures, function(i) i$id)]

bm_result_long <- melt(
  bm_result, 
  id.vars = "learner_id", 
  measure.vars = sapply(measures, function(i) i$id))

setnames(bm_result_long, "variable", "metric")
bm_result_long[, metric := as.character(metric)]
setorder(bm_result_long, "metric")

# PLOT --------------------------------------------------------------------

p <- ggplot(bm_result_long, aes(x = learner_id, y = metric, fill = value)) +
  geom_tile() +
  geom_text(aes(label = value), color = "white") +
  scale_fill_gradient(
    low = "darkgreen",
    high = "darkolivegreen3") +
  xlab("learner") +
  theme(text = element_text(size = 20), legend.position = "none")

ggsave("../figure/eval_mclass_benchmark.pdf", p, height = 4L, width = 8L)
