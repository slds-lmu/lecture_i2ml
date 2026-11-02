# goal here is to visualize typical results of impurity and permutation importance
# using mtcars (to allow interpretation), and show how similar the results are.

library(knitr)
library(ggplot2)
library(mlr3)
library(mlr3learners)
library(mlr3viz)
library(reshape2)
library(ggplot2)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

task = tsk("mtcars")

# permutation importance for all features
learner_perm = lrn("regr.ranger", importance = "permutation")
learner_perm$train(task)
importance_perm = learner_perm$importance()

# impurity importance for all features
learner_imp = lrn("regr.ranger", importance = "impurity")
learner_imp$train(task)
importance_imp = learner_imp$model$variable.importance

# convert importances to data frames for plotting
importance_perm_df = data.frame(Feature = names(importance_perm), Importance = importance_perm)
importance_imp_df = data.frame(Feature = names(importance_imp), Importance = importance_imp)

# plotting & saving permutation importance
ggplot(importance_perm_df, aes(x = reorder(Feature, Importance), y = Importance)) +
  geom_col(fill = "#66CDAA") +
  coord_flip() +
  labs(x = "features of task mtcars",
       y = "permutation importance: increase of MSE") +
  theme(
    axis.title.x = element_text(size = 12),
    axis.title.y = element_text(size = 12),
    axis.text.x = element_text(size = 10),
    axis.text.y = element_text(size = 12)
  )

ggsave("../figure/forest-fimp_perm.png", width = 4, height = 3)

# plotting & saving impurity importance
ggplot(importance_imp_df, aes(x = reorder(Feature, Importance), y = Importance)) +
  geom_col(fill = "#4682B4") +
  coord_flip() +
  labs(x = "features of task mtcars",
       y = "impurity importance: decrease in Gini impurity") +
  theme(
    axis.title.x = element_text(size = 12),
    axis.title.y = element_text(size = 12),
    axis.text.x = element_text(size = 10),
    axis.text.y = element_text(size = 12)
  )

ggsave("../figure/forest-fimp_gini.png", width = 4, height = 3)