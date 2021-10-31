library(mlbench)
library(mlr3)
library(mlr3learners)
library(mlr3viz)

set.seed(123L)

spiral <- mlbench.spirals(n = 500, sd = 0.1)
df_spiral <- as.data.frame(spiral)

plot(spiral$x, pch=19, col=c("blue", "orange")[spiral$classes])

task <- TaskClassif$new(id = "spirals_task", backend = df_spiral, 
                        target = "classes")

plot_learner_prediction(lrn("classif.lda"), task)
plot_learner_prediction(lrn("classif.qda"), task)
plot_learner_prediction(lrn("classif.log_reg"), task)
plot_learner_prediction(lrn("classif.kknn", k = 5), task)
plot_learner_prediction(lrn("classif.kknn", k = 1), task)
plot_learner_prediction(lrn("classif.kknn", k = 100), task)
