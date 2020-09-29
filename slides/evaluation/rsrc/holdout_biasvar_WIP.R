# PREREQ -----------------------------------------------------------------------

# create holdout-bias-var.png (not used) and holdout-biasvar.RData 
# (used in intro-performance and resampling)

library(mlr3)
library(BBmisc)
library(ggplot2)

# DATA -------------------------------------------------------------------------

set.seed(123)

n_reps = 50
ss_iters = 50
split_rates = seq(0.05, 0.95, by = 0.05)
n_1 = 100000
n_2 = 500

# SIMULATION -------------------------------------------------------------------

learner = lrn("classif.rpart")

generator = tgen("spirals", sd = 0.1)
task_1 = generator$generate(n_1)

resampling = rsmp("subsampling", repeats = ss_iters * 10, ratio = n_2 / n_1)

resampled = resample(task_1, learner, resampling, store_models = FALSE)
real_performance = resampled$aggregate()

res = array(NA, 
            dim = c(length(split_rates), ss_iters, n_reps), 
            dimnames = list(split_rates, 1:ss_iters, 1:n_reps))

for (i in 1:n_reps) {
  
  copy = task_1$clone()
  sbst = sample(n_1, n_2)
  task_2 = copy$filter(sbst)
  
  for (j in seq_along(split_rates)) {
    
    sr = split_rates[j]
    messagef("rep = %i;  splitrate = %g", i, sr)
    
    resampling_2 = rsmp("subsampling", repeats = ss_iters, ratio = sr)
    
    r = mlr3::resample(task_2, learner, resampling_2, store_models = FALSE)
    
    res[j, , i] = data.frame(r$score(msr("classif.ce")))$classif.ce
    
  }
  
}

save2(file = "holdout-biasvar.RData", 
      n1 = n_1, 
      n2 = n_2,
      nreps = n_reps, 
      ss.iters = ss_iters, 
      split.rates = split_rates,
      res = res, 
      r1 = resampled, 
      realperf = real_performance)

# ggd1 = melt(res)
# colnames(ggd1) = c("split", "rep", "ssiter", "mmce")
# ggd1$split = as.factor(ggd1$split)
# ggd1$mse = (ggd1$mmce -  realperf)^2 
# ggd1$type = "ho"
# ggd1$ssiter = NULL
# mse1 = ddply(ggd1, "split", summarize, mse = mean(mse))
# mse1$type = "ho"
# 
# 
# ggd2 = ddply(ggd1, c("split", "rep"), summarize, mmce = mean(mmce))
# ggd2$mse = (ggd2$mmce -  realperf)^2 
# ggd2$type = "ss"
# mse2 = ddply(ggd2, "split", summarize, mse = mean(mse))
# mse2$type = "ss"
# 
# ggd = rbind(ggd1, ggd2)
# ggd$split.and.type = paste(0, ggd$split, ggd$type)
# gmse = rbind(mse1, mse2)
# 
# pl1 = ggplot(ggd, aes(x = split.and.type, y = mmce))
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
# visualize the perfomance estimator - and the MSE of the estimator in 
# relation to the true error rate