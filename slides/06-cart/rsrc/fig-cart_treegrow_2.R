# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)
library(mlr3)
library(mlr3viz)

# DATA -------------------------------------------------------------------------

task = tsk("iris")
task$select(c("Sepal.Length", "Sepal.Width"))
task$filter(seq(1, 150, by = 20))

data = data.frame(task$data())

learner = lrn("classif.rpart", cp = 0, minbucket = 1, maxdepth = 1)

# PLOT -------------------------------------------------------------------------

pdf("../figure/cart_treegrow_4.pdf", width = 8, height = 4)

pl = plot_learner_prediction(learner, task)
pl = pl + geom_point(data, 
                     mapping = aes(x = Sepal.Length, y = Sepal.Width),
                     shape = 1)
pl = pl + theme(legend.position = "none")
print(pl)

ggsave("../figure/cart_treegrow_4.pdf", width = 8, height = 4)
dev.off()
