# ------------------------------------------------------------------------------
# FIG: 0-1 LOSS
# ------------------------------------------------------------------------------

# DATA -------------------------------------------------------------------------

x <- seq(-2L, 2L, by = 0.01)
y <- as.numeric(x < 0L)

# PLOTS ------------------------------------------------------------------------

# p <- ggplot2::qplot(
#   x, 
#   y, 
#   geom = "line",
#   xlab = expression(r = yf(x)),
#   ylab = expression(L(y, f(x))))

p <- ggplot2::ggplot(data.frame(x, y), aes(x = x, y = y)) + 
  geom_line(size = 1.2) +
  xlab(expression(yf(x))) +
  ylab(expression(L(y, f(x))))

p <- p + theme_minimal()
p <- p + theme(text = element_text(size = 20L))

ggplot2::ggsave("../figure/plot_loss_01.png", p, height = 4L, width = 10L)

