# PREREQ -----------------------------------------------------------------------

library(ggplot2)
library(mlr3)
library(mlr3viz)

# DATA -------------------------------------------------------------------------

is.even = function(x) if ((x[1] + x[2]) %% 2 == 0) {0} else {1}
df = expand.grid(1:10, 1:10)
names(df) = c("x1", "x2")
y = as.factor(apply(X=df, MARGIN = 1, FUN = is.even))
df = data.frame(df, y)

# MODEL -----------------------------------------------------------------------

task = as_task_classif(df, id = "chess", target = "y")
learner = lrn("classif.kknn", k=3, kernel = "rectangular", distance = 2, predict_type = "prob")

# PLOT -------------------------------------------------------------------------

p = plot_learner_prediction(learner, task)
p = p + scale_fill_viridis_d(end = .9, name = "Prediction") + guides(shape = FALSE, alpha = FALSE)
p

ggsave("../figure/eval_bad_model_auc.pdf", p, width = 8L, height = 4L)

# AUC -------------------------------------------------------------------------

predictions = learner$train(task)$predict_newdata(df)
auc = msr("classif.auc")$score(predictions)
auc

