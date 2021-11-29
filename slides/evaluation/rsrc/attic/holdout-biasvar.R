# create holdout-bias-var.png (not used) and holdout-biasvar.RData (used in intro-performance and resampling)

library(mlbench)
library(BBmisc)
library(mlr)
library(reshape2)
library(ggplot2)
library(gridExtra)
library(plyr)

set.seed(123)

nreps = 50
ss.iters = 50
split.rates = seq(0.05, 0.95, by = 0.05)
n1 = 100000
n2 = 500

lrn = makeLearner("classif.rpart")
task1 = convertMLBenchObjToTask("mlbench.spirals", n1, sd = 0.1)

r1 = subsample(lrn, task1, iters = ss.iters * 10, split = n2 / n1, keep.pred = FALSE)
realperf = r1$aggr
res = array(NA, dim = c(length(split.rates), ss.iters, nreps),
 dimnames = list(split.rates, 1:ss.iters, 1:nreps))

for (i in 1:nreps) {
 task2 = subsetTask(task1, subset = sample(n1, n2))
 for (j in seq_along(split.rates)) {
   sr = split.rates[j]
   messagef("rep = %i;  splitrate = %g", i, sr)
   r = subsample(lrn, task2, iters = ss.iters, split = sr, show.info = FALSE)
   res[j, , i] = r$measures.test[, "mce"]
 }
}
save2(file = "holdout-biasvar.RData", n1 = n1, n2 = n2,
 nreps = nreps, ss.iters = ss.iters, split.rates = split.rates,
 res = res, r1 = r1, realperf = realperf)

# ggd1 = melt(res)
# colnames(ggd1) = c("split", "rep", "ssiter", "mce")
# ggd1$split = as.factor(ggd1$split)
# ggd1$mse = (ggd1$mce -  realperf)^2
# ggd1$type = "ho"
# ggd1$ssiter = NULL
# mse1 = ddply(ggd1, "split", summarize, mse = mean(mse))
# mse1$type = "ho"
# 
# 
# ggd2 = ddply(ggd1, c("split", "rep"), summarize, mce = mean(mce))
# ggd2$mse = (ggd2$mce -  realperf)^2
# ggd2$type = "ss"
# mse2 = ddply(ggd2, "split", summarize, mse = mean(mse))
# mse2$type = "ss"
# 
# ggd = rbind(ggd1, ggd2)
# ggd$split.and.type = paste(0, ggd$split, ggd$type)
# gmse = rbind(mse1, mse2)
# 
# pl1 = ggplot(ggd, aes(x = split.and.type, y = mce))
# pl1 = pl1 + geom_boxplot()
# pl1 = pl1 + geom_hline(yintercept = realperf)
# pl1 = pl1 + theme(axis.text.x = element_text(angle = 45))
# 
# gmse$split = as.numeric(as.character(gmse$split))
# gmse$type = as.factor(gmse$type)
# pl2 = ggplot(gmse, aes(x = split, y = mse, col = type))
# pl2 = pl2 + geom_line()
# pl2 = pl2 + scale_y_log10()
# 
# pl = grid.arrange(pl1, pl2)
# print(pl)
# save(pl, file = "figure_man/holdout-bias-var.png")


# experiment:
# spiral data from mlbench(with sd = 0.1)
# learner = CART (classif.rpart from mlr)
# goal: estimate real performance of a model with |D_train| = 1000
# get "true" estimator by repeatedly sampling 1000 obs from the simulator,
#   fit the learner, then evaluate on a really large number of observation
# now analyse different forms of holdout, with different split rates
# sample D with |D| = 500
# split-rate = c(0.05, 0.1, ..., 0.9, 0.95) for training with |Dtrain| = s 500
# estimate performance on D_test with |Dtest| = 500 (1 - s)
# repeat the sampöing of D 50 times, and the splitiing with s 50 times
# (so 2500 exps per split rate)
# visualize the perfomance estimator - and the MSE of the estimator in relation to the
# true error rate




