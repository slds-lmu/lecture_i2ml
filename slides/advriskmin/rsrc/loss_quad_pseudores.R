# ------------------------------------------------------------------------------
# FIG: QUADRATIC LOSS WITH PSEUDO-RESIDUAL
# ------------------------------------------------------------------------------

# DATA -------------------------------------------------------------------------

x <- seq(-2L, 2L, by = 0.01)
y <- x^2

# PLOTS ------------------------------------------------------------------------

p <- ggplot2::qplot(
  x, 
  y, 
  geom = "line",
  xlab = bquote(y - f(x)),
  ylab = bquote(L(y, f(x))))

p <- p + 
  ggplot2::geom_segment(
    mapping = aes(x = 0.5, xend = 2L, y = 0L, yend = 3L),
    col = "red") +
  ggplot2::geom_segment(
    mapping = aes(x = 1L, xend = 1L, y = 0L, yend = 1L),
    col = "red") +
  ggplot2::geom_point(
    mapping = aes(x = 1L, y = 1L),
    col = "red",
    size = 3L,
    shape = 1L) +
  ggplot2::annotate(
    "text", 
    x = 0L, 
    y = 3L, 
    label = bquote(L(y, f(x)) ~ "=" ~ (y - f(x))^2), 
    size = 7L)

p <- p + theme_bw()
p <- p + theme(text = element_text(size = 20L))

ggplot2::ggsave(
  "../figure/plot_quad_pseudores.png", 
  p, 
  height = 4L, 
  width = 10L)

