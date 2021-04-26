# ------------------------------------------------------------------------------
# FIG: EXPONENTIAL LOSS
# ------------------------------------------------------------------------------

library(ggplot2)

# DATA -------------------------------------------------------------------------

x <- seq(-2L, 2L, by = 0.01)
y <- exp(-x)

# PLOTS ------------------------------------------------------------------------

p <- ggplot2::ggplot(data.frame(x, y), aes(x = x, y = y)) + 
  geom_line(size = 1.2) +
  xlab(expression(yf(x))) +
  ylab(expression(L(y, f(x)))) + 
  theme_minimal() +
  theme(text = element_text(size = 30L))

ggplot2::ggsave(
  "../figure/plot_loss_exponential.png", 
  p, 
  height = 4L, 
  width = 12L)

