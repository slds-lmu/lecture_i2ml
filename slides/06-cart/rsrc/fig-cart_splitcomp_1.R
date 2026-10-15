# PREREQ -----------------------------------------------------------------------

library(knitr)
library(mlr3)
library(mlr3viz)
library(ggplot2)
library(rattle)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# DATA -------------------------------------------------------------------------

set.seed(600000)

x = c(1, 2, 7, 10, 20)
y = c(1, 1, 0.5, 10, 11)
data = data.frame(x = x, y = y)

task = TaskRegr$new(id = "example", backend = data, target = "y")

learner = lrn("regr.rpart", minsplit = 5)
learner$train(task)

mod = learner$model

# Check the prediction and the SSE in each node

yval1 = mod$frame$yval[2]
yval2 = mod$frame$yval[3]
SSE1 = mod$frame$dev[2]
SSE2 = mod$frame$dev[3]

# Create tree with x being log-transformed

x_log = log(x)
data_log = tibble(x_log = x_log, y = y)

task_log = TaskRegr$new(id = "example_log", backend = data_log, target = "y")

learner_log = learner$clone()
learner_log$train(task_log)
mod_log = learner_log$model

# Check predictions and SSE

yval1_log = mod_log$frame$yval[2]
yval2_log = mod_log$frame$yval[3]
SSE1_log = mod_log$frame$dev[2]
SSE2_log = mod_log$frame$dev[3]

# PLOT 1 -----------------------------------------------------------------------

pdf("../figure/cart_splitcomp_1.pdf", width = 6, height = 4)

fancyRpartPlot(mod, sub = "")

ggsave("../figure/cart_splitcomp_1.pdf", width = 6, height = 4)
dev.off()

# PLOT 2 -----------------------------------------------------------------------

pdf("../figure/cart_splitcomp_2.pdf", width = 6, height = 4)

fancyRpartPlot(mod_log, sub = "")

ggsave("../figure/cart_splitcomp_2.pdf", width = 6, height = 4)
dev.off()