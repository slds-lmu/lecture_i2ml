# PREREQ -----------------------------------------------------------------------

library(knitr)
library(mlr3)
library(mlr3viz)
library(ggplot2)

# FUNCTIONS --------------------------------------------------------------------

fn = function(x) (sin(4 * x - 4)) * ((2 * x - 2)^2) * (sin(20 * x - 4))

# DATA -------------------------------------------------------------------------

set.seed(600000)

d = data.frame(x = seq(0.2, 1, length.out = 7))
d$y = fn(d$x)

x = seq(0.2, 1, length.out = 500)
dd = data.frame(x = x, y = fn(x))

task = TaskRegr$new(id = "sinus", backend = d, target = "y")
learner = lrn("regr.rpart", minbucket = 1, minsplit = 1)

# PLOT -------------------------------------------------------------------------

pdf("../figure/cart_dis_2.pdf", width = 8, height = 5)

pl = plot_learner_prediction(learner, task)
pl = pl + scale_color_manual(values = c("red", "black"))
pl = pl + geom_line(data = dd, aes(x, y, color = "red"))
pl = pl + theme(legend.position = "none")
print(pl)

ggsave("../figure/cart_dis_2.pdf", width = 8, height = 5)
dev.off()