# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)
library(mlr3)
library(mlr3learners)
library(mlr3viz)
library(reshape2)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# DATA -------------------------------------------------------------------------
task = tsk("mtcars")

# permutation
learner_perm = lrn("regr.ranger", importance = "permutation")
learner_perm$train(task)
importance_perm = learner_perm$importance()

# impurity
learner_imp = lrn("regr.ranger", importance = "impurity")
learner_imp$train(task)
importance_imp = learner_imp$model$variable.importance

# convert importances to data frames for plotting
importance_perm_df = data.frame(Feature = names(importance_perm), Importance = importance_perm)
importance_imp_df = data.frame(Feature = names(importance_imp), Importance = importance_imp)

# PLOT -------------------------------------------------------------------------

ggplot(importance_perm_df, aes(x = reorder(Feature, Importance), y = Importance)) +
  geom_col(fill = "#4682B4") +
  coord_flip() +
  labs(x = "features of task mtcars",
       y = "permutation importance: increase of MSE")

ggsave("../figure/forest-fimp_perm.png", width = 8, height = 2.8)

ggplot(importance_imp_df, aes(x = reorder(Feature, Importance), y = Importance)) +
  geom_col(fill = "#66CDAA") +
  coord_flip() +
  labs(x = "features of task mtcars",
       y = "impurity importance: decrease in Gini impurity")

ggsave("../figure/forest-fimp_gini.png", width = 8, height = 2.8)