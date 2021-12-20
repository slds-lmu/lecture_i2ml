# ------------------------------------------------------------------------------
# FIG: 0-1 LOSS
# ------------------------------------------------------------------------------

library(ggplot2)

# DATA -------------------------------------------------------------------------

x <- seq(-2L, 2L, by = 0.01)
y <- as.numeric(x < 0L)

# PLOTS ------------------------------------------------------------------------

p <- ggplot2::ggplot(data.frame(x, y), aes(x = x, y = y)) + 
  geom_line(size = 1.2) +
  xlab(expression(yf(x))) +
  ylab(expression(L(y, f(x))))

p <- p + theme_classic()
p <- p + theme(text = element_text(size = 20L))

ggplot2::ggsave("../figure/plot_loss_01.png", p, height = 3L, width = 5L)

