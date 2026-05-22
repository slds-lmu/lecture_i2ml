# ------------------------------------------------------------------------------
# PLOT SHOWING EMPIRICAL DENSITY OF POINT-WISE LOSSES --------------------------
# ------------------------------------------------------------------------------

# DATA -------------------------------------------------------------------------

library(mlr3)
library(mlr3learners)
library(mlbench)
library(ggplot2)
set.seed(1L)

#task <- mlr3::tsk("boston_housing")
ntrain = 500
ntest = 5000
n = ntrain + ntest
  
data = as.data.frame(mlbench.friedman1(n))
#dtest = as.data.frame(mlbench.friedman1(500))
task = TaskRegr$new("foo", backend = data, target = "y")
#task$select(task$feature_names[!task$feature_names %in% c("town", "chas")])

#train_set = sample(task$nrow, 0.7 * task$nrow)
#test_set = setdiff(seq_len(task$nrow), train_set)

learner <- mlr3::lrn("regr.lm")
learner$train(task, row_ids = 1:ntrain)

losses = sapply((ntrain+1):n, function(i) 
  learner$predict(task, row_ids = i)$score())


# PLOT -------------------------------------------------------------------------
losses_mu = mean(losses)


p <- ggplot2::ggplot(data.frame(x = losses), ggplot2::aes(x)) +
  ggplot2::geom_density() +
  ggplot2::scale_x_log10(limits = c(1e-2, 1e2)) + 
  ggplot2::labs(x = "L2 loss (log scale)") 
p = p + geom_vline(xintercept = losses_mu)


#print(p)

ggplot2::ggsave(
 "../figure/fig_loss_distribution.png",
 p,
 height = 2L,
width = 3.5)
