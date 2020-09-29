# PREREQ -----------------------------------------------------------------------

library(knitr)
library(mlr3)

# DATA -------------------------------------------------------------------------

task = tsk("boston_housing")
task$select(mlr::getTaskFeatureNames(mlr::bh.task))

learner = lrn("regr.rpart", maxdepth = 2)
learner$train(task)
mod = learner$model

set.seed(123)
cps = rev(mod$cptable[-4, "CP"])

# FUNCTIONS --------------------------------------------------------------------

plot_rpart = function(x) {
  
  p = rpart::prune(mod, cp = x)
  sub_title = sprintf("Pruning with complexity parameter = %.3f.", x)
  rattle::fancyRpartPlot(p, sub = sub_title)
  
}

# PLOT 1 -----------------------------------------------------------------------

pdf("../figure/cart_stopprun_1.pdf", width = 8, height = 5.8)

rattle::fancyRpartPlot(mod, sub = "Full tree")

ggsave("../figure/cart_stopprun_1.pdf", width = 8, height = 5.8)
dev.off()

# PLOT 2 -----------------------------------------------------------------------

pdf("../figure/cart_stopprun_2.pdf", width = 8, height = 5.8)

lapply(cps[1], plot_rpart)

ggsave("../figure/cart_stopprun_2.pdf", width = 8, height = 5.8)
dev.off()

# PLOT 3 -----------------------------------------------------------------------

pdf("../figure/cart_stopprun_3.pdf", width = 8, height = 5.8)

lapply(cps[2], plot_rpart)

ggsave("../figure/cart_stopprun_3.pdf", width = 8, height = 5.8)
dev.off()

# PLOT 4 -----------------------------------------------------------------------

pdf("../figure/cart_stopprun_4.pdf", width = 8, height = 5.8)

lapply(cps[3], plot_rpart)

ggsave("../figure/cart_stopprun_4.pdf", width = 8, height = 5.8)
dev.off()