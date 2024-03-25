# PREP -------------------------------------------------------------------------

# Download data
url <- "https://archive.ics.uci.edu/ml/machine-learning-databases/abalone/abalone.data"
abalone <- read.table(url, sep = ",", row.names = NULL)
colnames(abalone) <- c(
  "sex", "longest_shell", "diameter", "height", "whole_weight", 
  "shucked_weight", "visceral_weight", "shell_weight", "rings")

# Reduce to relevant columns
abalone <- abalone[, c("longest_shell", "whole_weight", "rings")]

# a) ---------------------------------------------------------------------------

library(ggplot2)

# Plot weight vs shell length
ggplot2::ggplot(
  abalone, 
  aes(x = longest_shell, y = whole_weight, col = rings)) +
  ggplot2::geom_point(alpha = 0.7) +
  ggplot2::scale_color_viridis_c() +
  ggplot2::labs(
    x = "longest shell", 
    y = "whole weight",
    title = "Weight vs shell length for abalone data")

# We see that weight scales exponentially with shell length and that larger /
# heavier animals tend to have more rings.

# b) ---------------------------------------------------------------------------

library(mlr3)

# Specify regression task
task_abalone <- mlr3::TaskRegr$new(
  id = "abalone", backend = abalone, target = "rings")

# c) ---------------------------------------------------------------------------

library(mlr3learners)

# Set up LM, train (by default, the target will be regressed on all features, 
# i.e., target ~ .)
learner_lm <- mlr3::lrn("regr.lm")

# Train and predict
learner_lm$train(task_abalone)
pred_lm <- learner_lm$predict(task_abalone)

# Inspect predictions
head(data.frame(
  id = 1:length(pred_lm$truth), 
  truth = pred_lm$truth,
  response = pred_lm$response))

# d) ---------------------------------------------------------------------------

library(mlr3viz)

# Get nice visualization with a one-liner
mlr3viz::autoplot(pred_lm)

# We see a scatterplot of true vs predicted values, where the small bars along 
# the axes (a so-called rugplot) indicate the number of observations that fall 
# into this area.
# As we might have suspected from the first plot, the underlying relationship 
# is not exactly linear (ideally, all points and the resulting line should lie 
# on the diagonal). With a linear model we tend to underestimate the response.

# e) ---------------------------------------------------------------------------

# Define MAE metric
mae <- mlr3::msr("regr.mae")

# Assess performance (MSE by default)
pred_lm$score()
pred_lm$score(mae)

# ------------------------------------------------------------------------------

# While we focus on "learning to predict" here, we can of course also do the 
# usual model interpretation, e.g., examining the coefficients.

# All effects highly significant
summary(learner_lm$model)

# Not-so-homoskedastic residuals
ggplot2::ggplot(
  data.frame(
    x = learner_lm$model$fitted.values, 
    y = learner_lm$model$residuals),
  aes(x, y)) + 
  ggplot2::geom_point()
