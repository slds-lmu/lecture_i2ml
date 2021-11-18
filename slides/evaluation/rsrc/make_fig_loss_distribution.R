# ------------------------------------------------------------------------------
# PLOT SHOWING EMPIRICAL DENSITY OF POINT-WISE LOSSES --------------------------
# ------------------------------------------------------------------------------

# DATA -------------------------------------------------------------------------

library(mlr3)
library(mlr3learners)

task <- mlr3::tsk("boston_housing")
task$select(task$feature_names[!task$feature_names %in% c("town", "chas")])

set.seed(1L)
train_set = sample(task$nrow, 0.7 * task$nrow)
test_set = setdiff(seq_len(task$nrow), train_set)

learner <- mlr3::lrn("regr.lm")
learner$train(task, row_ids = train_set)

predictions <- sapply(
  seq_len(nrow(task$data()[test_set])), 
  function(i) learner$predict_newdata(task$data()[test_set][i, ]))

losses <- sapply(predictions, function(i) i$score())

# PLOT -------------------------------------------------------------------------

p <- ggplot2::ggplot(data.frame(x = losses), ggplot2::aes(x)) +
  ggplot2::geom_density() +
  ggplot2::scale_x_log10(
    breaks = scales::trans_breaks("log10", function(x) 10^x)) + 
  ggplot2::labs(x = "mean squared error (log scale)")

dt_density <- ggplot2::ggplot_build(p)$data[[1]]
x_mode <- dt_density$x[which.max(dt_density$density)]
d_mode <- max(dt_density$density)
d_sd <- sd(dt_density$x)
  
p <- p + ggplot2::geom_segment(
    x = x_mode,
    xend = x_mode,
    y = -0.01,
    yend = d_mode,
    col = "darkgray") +
  ggplot2::geom_segment(
    x = x_mode - d_sd,
    xend = x_mode + d_sd,
    y = -0.01,
    yend = -0.01,
    arrow = ggplot2::arrow(
      ends = "both", type = "closed", length = ggplot2::unit(0.2, "cm")),
    col = "darkgray")

ggplot2::ggsave(
  "../figure/fig_loss_distribution.png",
  p,
  height = 2L,
  width = 3.5)
