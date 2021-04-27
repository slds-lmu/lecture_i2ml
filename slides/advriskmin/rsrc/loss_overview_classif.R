# ------------------------------------------------------------------------------
# FIG: LOSSES OVERVIEW (CLASSIF LOSSES)
# ------------------------------------------------------------------------------

library(ggplot2)

# DATA -------------------------------------------------------------------------

x <- seq(-4L, 4L, length.out = 800L)

hinge <- ifelse(x < 1L, 1L - x, 0L)
hinge_sq <- ifelse(x < 1L, (1L - x)^2, 0L)
sq_scores <- (1 - x)^2
exp <- exp(-x)
zero_one <- as.numeric(x < 0L)

df <- tidyr::gather(
  data.frame(x, hinge, hinge_sq, sq_scores, exp, zero_one),
  "loss",
  "value",
  -x)

df$aux <- as.factor(ifelse(df$loss == "sq_scores", 1L, 0L))

# PLOTS ------------------------------------------------------------------------

p <- ggplot2::ggplot(df, aes(x = x, y = value, color = loss, linetype = aux)) + 
  ggplot2::geom_line(size = 1.1) +
  ggplot2::scale_color_viridis_d(
    end = 0.9,
    name = "",
    labels = c(
      "Exponential",
      "Hinge",
      "Squared hinge",
      "Squared (scores)",
      "0-1")) +
  ggplot2::guides(color = guide_legend(ncol = 2), linetype = FALSE) +
  ggplot2::ylim(c(0L, 4L)) +
  ggplot2::scale_x_continuous(breaks = seq(-4L, 4L)) +
  ggplot2::xlab(expression(yf(x))) +
  ggplot2::ylab(expression(L(y, f(x)))) +
  ggplot2::theme_minimal() +
  ggplot2::theme(
    text = element_text(size = 20L),
    legend.position = "bottom")

ggplot2::ggsave(
  "../figure/plot_loss_overview_classif.png", 
  p, 
  width = 6L, 
  height = 4L)
