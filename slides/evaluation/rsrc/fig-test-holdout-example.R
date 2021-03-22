# PREREQ -----------------------------------------------------------------------

library(data.table)
library(mlbench)
library(BBmisc)
library(mlr3)
library(ggplot2)
library(reshape2)
library(plyr)

# DATA -------------------------------------------------------------------------

set.seed(123L)

n_reps = 50L
ss_iters = 50L
split_rates = seq(0.05, 0.95, by = 0.05)
n_1 = 100000L
n_2 = 500L
data = data.table::as.data.table(mlbench::mlbench.spirals(n_1, sd = 0.1))

# EXPERIMENT -------------------------------------------------------------------

learner = mlr3::lrn("classif.rpart")
task = mlr3::TaskClassif$new("spirals", backend = data, target = "classes")

resampling = mlr3::rsmp(
  "subsampling", 
  ratio = n_2 / n_1, 
  repeats = ss_iters * 10L) 

resampling_result = mlr3::resample(
  task, 
  learner, 
  resampling, 
  store_models = FALSE)

true_performance = resampling_result$aggregate(mlr3::msr("classif.ce"))

results = array(
  NA, 
  dim = c(length(split_rates), ss_iters, n_reps),
  dimnames = list(split_rates, seq_len(ss_iters), seq_len(n_reps)))

for (i in seq_len(n_reps)) {
  
  task_subset = task$clone()$filter(sample(n_1, n_2))
  
  for (j in seq_along(split_rates)) {
    
    this_split = split_rates[j]
    mlr3misc::messagef("rep = %i;  splitrate = %g", i, this_split)
    
    resampling_result_subset = mlr3::resample(
      task_subset, 
      learner, 
      mlr3::rsmp(
        "subsampling", 
        ratio = this_split, 
        repeats = ss_iters))
    
    results[j, , i] = resampling_result_subset$score()$classif.ce
    
  }
  
}

# RESHAPING --------------------------------------------------------------------

ggd1 = reshape2::melt(results)
colnames(ggd1) = c("split", "rep", "ssiter", "mmce")
ggd1$split = as.factor(ggd1$split)
ggd1$mse = (ggd1$mmce -  true_performance)^2
ggd1$type = "holdout"
ggd1$ssiter = NULL

mse1 = plyr::ddply(ggd1, "split", plyr::summarize, mse = mean(mse))
mse1$type = "holdout"

ggd2 = plyr::ddply(ggd1, c("split", "rep"), plyr::summarize, mmce = mean(mmce))
ggd2$mse = (ggd2$mmce -  true_performance)^2
ggd2$type = "subsampling"
mse2 = plyr::ddply(ggd2, "split", plyr::summarize, mse = mean(mse))
mse2$type = "subsampling"

ggd = rbind(ggd1, ggd2)
gmse = rbind(mse1, mse2)
ggd$type = as.factor(ggd$type)
gmse$split = as.numeric(as.character(gmse$split))
gmse$type = as.factor(gmse$type)

# PLOT 1 -----------------------------------------------------------------------

pl1 = ggplot(ggd[ggd$type == "holdout", ], aes(x = split, y = mmce))
pl1 = pl1 + geom_boxplot()
pl1 = pl1 + geom_hline(yintercept = true_performance)
pl1 = pl1 + theme(axis.text.x = element_text(angle = 45))

ggsave("../figure/test-holdout-example.pdf", pl1, width = 8, height = 3.5)  

# PLOT 2 -----------------------------------------------------------------------

pl2 = ggplot(gmse[gmse$type == "holdout", ], aes(x = split, y = mse))
pl2 = pl2 + geom_line()
pl2 = pl2 + scale_y_log10()
pl2 = pl2 + scale_x_continuous(breaks = gmse$split)
pl2 = pl2 + theme(axis.text.x = element_text(angle = 45))

ggsave("../figure/test-holdout-example-2.pdf", pl2, width = 8, height = 3.5)  

# load("rsrc/holdout-biasvar.RData")
# ggd1 = reshape2::melt(res)
# colnames(ggd1) = c("split", "rep", "ssiter", "mmce")
# ggd1$split = as.factor(ggd1$split)
# ggd1$mse = (ggd1$mmce -  realperf)^2
# ggd1$type = "holdout"
# ggd1$ssiter = NULL
# mse1 = plyr::ddply(ggd1, "split", plyr::summarize, mse = mean(mse))
# mse1$type = "holdout"
# 
# ggd2 = plyr::ddply(ggd1, c("split", "rep"), plyr::summarize, mmce = mean(mmce))
# ggd2$mse = (ggd2$mmce -  realperf)^2
# ggd2$type = "subsampling"
# mse2 = plyr::ddply(ggd2, "split", plyr::summarize, mse = mean(mse))
# mse2$type = "subsampling"
# 
# ggd = rbind(ggd1, ggd2)
# gmse = rbind(mse1, mse2)
# ggd$type = as.factor(ggd$type)
# gmse$split = as.numeric(as.character(gmse$split))
# gmse$type = as.factor(gmse$type)
# 
# pl1 = ggplot(ggd[ggd$type == "holdout", ], aes(x = split, y = mmce))
# pl1 = pl1 + geom_boxplot()
# pl1 = pl1 + geom_hline(yintercept = realperf)
# pl1 = pl1 + theme(axis.text.x = element_text(angle = 45))
# print(pl1)
# 
# ggsave("figure/test-holdout-example.pdf", width = 8, height = 3.5)  
# 
# 
# pl2 = ggplot(gmse[gmse$type == "holdout", ], aes(x = split, y = mse))
# pl2 = pl2 + geom_line()
# pl2 = pl2 + scale_y_log10()
# pl2 = pl2 + scale_x_continuous(breaks = gmse$split)
# pl2 = pl2 + theme(axis.text.x = element_text(angle = 45))
# print(pl2)
# 
# ggsave("figure/test-holdout-example-2.pdf", width = 8, height = 3.5)  
