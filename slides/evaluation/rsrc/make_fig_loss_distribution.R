# ------------------------------------------------------------------------------
# PLOT SHOWING EMPIRICAL DENSITY OF POINT-WISE LOSSES --------------------------
# ------------------------------------------------------------------------------

# DATA -------------------------------------------------------------------------

library(mlr3)
library(mlr3learners)

task <- mlr3::tsk("boston_housing")
task$select(task$feature_names[!task$feature_names %in% c("town", "chas")])

set.seed(123L)
train_set = sample(task$nrow, 0.4 * task$nrow)
test_set = setdiff(seq_len(task$nrow), train_set)

learner <- mlr3::lrn("regr.lm")
learner$train(task, row_ids = train_set)

predictions <- sapply(
  seq_len(nrow(task$data()[test_set])), 
  function(i) learner$predict_newdata(task$data()[test_set][i, ]))

losses <- sapply(predictions, function(i) i$score())
log_losses <- log(losses)
mode <- max(density(log_losses)$y)
idx_mode = which.max(density(log_losses)$y)
x_mode <- density(log_losses)$x[idx_mode]
sd_log_losses <- sd(log_losses)

loss_trafo <- log10(losses)

# PLOT -------------------------------------------------------------------------

p <- ggplot2::ggplot(data.frame(x = losses), ggplot2::aes(x)) +
  ggplot2::geom_density() +
  ggplot2::scale_x_log10(
    breaks = scales::trans_breaks("log10", function(x) 10^x)) +
  ggplot2::geom_rug()
  # ggplot2::geom_segment(
  #   x = loss_trafo[which.max(density(loss_trafo)$y)],
  #   xend = mean(loss_trafo),
  #   y = 0L,
  #   yend = 0.5,
  #   col = "darkgray")
  # ggplot2::geom_segment(
  #   x = x_mode - sd_log_losses, 
  #   xend = x_mode + sd_log_losses,
  #   y = 0.01,
  #   yend = 0.01, 
  #   arrow = ggplot2::arrow(ends = "both"),
  #   col = "darkgray")
p

