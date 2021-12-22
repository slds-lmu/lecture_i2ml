# ------------------------------------------------------------------------------
# FIG: BRIER SCORE
# ------------------------------------------------------------------------------

library(ggplot2)

# DATA -------------------------------------------------------------------------

x <- seq(0L, 1L, by = 0.01)

df <- rbind(
  data.frame(x, y = 1L, pi = (1 - x)^2),
  data.frame(x, y = 0L, pi = x^2))

df$y <- as.factor(df$y)

# PLOTS ------------------------------------------------------------------------

p <- ggplot2::ggplot(data = df, aes(x = x, y = pi, color = y)) + 
  geom_line(size = 1.2) + 
  xlab(expression(pi(x))) + 
  ylab(expression(L(y, pi(x)))) + 
  theme_minimal() +
  theme(text = element_text(size = 20L)) +
  scale_color_viridis_d(end = 0.9)

ggplot2::ggsave(
  "../figure/plot_brier.png", 
  p,
  height = 4L,
  width = 10L)
