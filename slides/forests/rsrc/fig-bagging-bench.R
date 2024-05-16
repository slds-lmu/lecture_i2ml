# goal here is to visualize the need for unstable learners in bagging
# by using a benchmark_grid from mlr3
# and later show how RF further improve accuracy!

library(mlr3)
library(mlr3learners)
library(mlr3pipelines)
library(mlr3viz)
library(ggplot2)
library(data.table)

set.seed(123)

# bagging via a pipeline (taken from mlr3 book)
create_bagging_pipeline <- function(base_learner) {
  gr_single_pred = po("subsample", frac = 1, replace=TRUE) %>>% lrn(base_learner) # equals bootstrapping (with replacement, frac = 1)
  gr_pred_set = ppl("greplicate", graph = gr_single_pred, n = 100)
  gr_bagging = gr_pred_set %>>% po("classifavg", innum = 100)
  as_learner(gr_bagging)
}

# setup learners
glrn_bagging_log = create_bagging_pipeline("classif.log_reg")
glrn_bagging_log$id = "bagging_logistic"

glrn_bagging_rpart = create_bagging_pipeline("classif.rpart")
glrn_bagging_rpart$id = "bagging_tree"

glrn_bagging_kknn = create_bagging_pipeline("classif.kknn")
glrn_bagging_kknn$id = "bagging_kknn"

lrn_log_reg = lrn("classif.log_reg")
lrn_rpart = lrn("classif.rpart")
lrn_ranger = lrn("classif.ranger")
lrn_kknn = lrn("classif.kknn")
lrn_kknn$param_set$values$k = 7

# benchmark_grid expects a list:
learners = list(glrn_bagging_log, lrn_log_reg, glrn_bagging_rpart, lrn_rpart, glrn_bagging_kknn, lrn_kknn, lrn_ranger)

# tasks to be included in the benchmark
tasks = lapply(c("spam"), tsk)

# run the benchmark!
bmr = benchmark(benchmark_grid(tasks, learners, rsmp("cv", folds = 10)))
results = bmr$aggregate()

# visualization
data <- as.data.table(results)
data[, learner_id := factor(learner_id,
                            levels = c("classif.log_reg", "bagging_logistic", "bagging_tree", "classif.rpart", "classif.kknn", "bagging_kknn", "classif.ranger"),
                            labels = c("LR", "LR bagged", "CART bagged", "CART", "7-nn", "7-nn bagged", "RF"))]
data_spam <- data[task_id == "spam"]

a <- autoplot(bmr, type = "boxplot") +
       ggtitle("spam")
       ylab("CE for 10-fold CV") +
       xlab("Learners") +
       scale_x_discrete(labels = c("LR", "LR bagged", "CART bagged", "CART", "7-nn", "7-nn bagged", "RF")) +
       theme_minimal() +
       theme(
             axis.title = element_text(size = 14),
             axis.text = element_text(size = 12),
             legend.title = element_text(size = 14),
             legend.text = element_text(size = 12)
         )
ggsave("../figure/bagging-bench_RF.png", plot = a, width = 16, height = 8, dpi = 300)
