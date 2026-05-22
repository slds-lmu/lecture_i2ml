# goal here is to visualize the need for unstable learners in bagging
# by using a benchmark_grid from mlr3 on the spam task (as always in our RF chapter)
# and later show how RFs further improve accuracy!

library(mlr3)
library(mlr3learners)
library(mlr3pipelines)
library(mlr3viz)
library(ggplot2)
library(data.table)

set.seed(123)

task = tsk("spam")
ntree = 100
p = length(task$feature_names)

create_bagging_pipeline <- function(lrn) {
  pl = po("subsample", frac = 1, replace = TRUE) %>>% lrn # bootstrap
  pl = ppl("greplicate", graph = pl, n = ntree)
  pl = pl %>>% po("classifavg", innum = ntree)
  as_learner(pl)
}

# setup learners
lrn_log = lrn("classif.log_reg")
lrn_log_bagged = create_bagging_pipeline(lrn_log); lrn_log_bagged$id = "bagging_logistic"

lrn_kknn = lrn("classif.kknn", k = 7)
lrn_kknn_bagged = create_bagging_pipeline(lrn_kknn); lrn_kknn_bagged$id = "bagging_kknn"

# using package defaults
lrn_rpart = lrn("classif.rpart")
lrn_ranger = lrn("classif.ranger", num.trees = 100)

# exploring effects of expansion and mtry
lrn_ranger_st_nomtry_noexp = lrn("classif.ranger", id = "ranger_st_nomtry_noexp",
  oob.error = FALSE, num.trees = 1, replace = FALSE, sample.fraction = 1, mtry = p, min.node.size = 20, min.bucket = 7) 
lrn_ranger_st_nomtry_fullexp = lrn("classif.ranger", id = "ranger_st_nomtry_fullexp", 
  oob.error = FALSE, num.trees = 1, replace = FALSE, sample.fraction = 1, mtry = p, min.node.size = 1, min.bucket = 1) 
lrn_ranger_st_mtry_noexp = lrn("classif.ranger", id = "ranger_st_mtry_noexp", 
  oob.error = FALSE, num.trees = 1, replace = FALSE, sample.fraction = 1, min.node.size = 20, min.bucket = 7) 

lrn_ranger_stbag_nomtry_noexp = create_bagging_pipeline(lrn_ranger_st_nomtry_noexp); lrn_ranger_stbag_nomtry_noexp$id =
  "ranger_stbag_nomtry_noexp"
lrn_ranger_stbag_nomtry_fullexp = create_bagging_pipeline(lrn_ranger_st_nomtry_fullexp); lrn_ranger_stbag_nomtry_fullexp$id =
  "ranger_stbag_nomtry_fullexp"
lrn_ranger_stbag_mtry_noexp = create_bagging_pipeline(lrn_ranger_st_mtry_noexp); lrn_ranger_stbag_mtry_noexp$id =
  "ranger_stbag_mtry_noexp"

# benchmark_grid expects a list:
learners = list(lrn_kknn, lrn_kknn_bagged, lrn_log, lrn_log_bagged, lrn_rpart, lrn_ranger_stbag_nomtry_noexp,
                lrn_ranger_stbag_nomtry_fullexp, lrn_ranger_stbag_mtry_noexp, lrn_ranger)

# run the benchmark!
bmr = benchmark(benchmark_grid(task, learners, rsmp("cv", folds = 10)))

# visualization
a <- autoplot(bmr, type = "boxplot") +
  ylab("CE for 10-fold CV") +
  xlab("Learners") +
  scale_x_discrete(labels = c("7-nn", "7-nn bagged", "LR", "LR bagged", "CART", "CART bagged", "CART bagged: full exp", "CART bagged: mtry", "RF")) +
  theme_minimal() +
  theme(
    axis.title = element_text(size = 22, face = "bold"),
    axis.text = element_text(size = 20, face = "bold"),
    legend.title = element_text(size = 22, face = "bold"),
    legend.text = element_text(size = 20, face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )
ggsave("../figure/bagging-bench.png", plot = a, width = 12, height = 8, dpi = 300)
