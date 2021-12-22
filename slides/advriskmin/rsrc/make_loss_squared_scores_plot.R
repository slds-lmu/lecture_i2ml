# ------------------------------------------------------------------------------
# FIG: SQUARED LOSS ON SCORES
# ------------------------------------------------------------------------------

library(ggplot2)

# DATA -------------------------------------------------------------------------

x <- seq(-4L, 4L, by = 0.01)
y <- (1 - x)^2

# PLOTS ------------------------------------------------------------------------

p <- ggplot2::ggplot(data.frame(x, y), aes(x = x, y = y)) + 
  geom_line(size = 1.2) +
  scale_x_continuous(breaks = seq(-4L, 4L)) +
  xlab(expression(yf(x))) +
  ylab(expression(L(y, f(x)))) + 
  theme_minimal() +
  theme(text = element_text(size = 30L))

ggplot2::ggsave(
  "../figure/plot_loss_squared_scores.png", 
  p, 
  height = 4L, 
  width = 12L)

