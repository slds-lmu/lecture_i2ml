# PREREQ -----------------------------------------------------------------------

library(knitr)
library(mlr3)
library(mlr3viz)
library(ggplot2)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# DATA -------------------------------------------------------------------------

set.seed(123)

n = 100
data = data.frame(x1 = runif(n), x2 = runif(n))
data$y = as.factor(with(data, as.integer(x1 > x2)))

task = TaskClassif$new("task", 
                       backend = data, 
                       target = "y")

learner = lrn("classif.rpart", cp = 0, minbucket = 2, maxdepth = 6)

# PLOT -------------------------------------------------------------------------

pdf("../figure/cart_dis_1.pdf", width = 8, height = 5)

pl = plot_learner_prediction(learner, task, grid_points = 300)
pl = pl + geom_abline(slope = 1, linetype = 2)
pl = pl + guides(shape = FALSE)
print(pl)

ggsave("../figure/cart_dis_1.pdf", width = 8, height = 5)
dev.off()
