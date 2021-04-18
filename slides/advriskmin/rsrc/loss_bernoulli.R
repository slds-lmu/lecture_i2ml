# ------------------------------------------------------------------------------
# FIG: BERNOULLI LOSS
# ------------------------------------------------------------------------------

# DATA -------------------------------------------------------------------------

x_1 <- seq(-4L, 4L, by = 0.01)
y <- log(1L + exp(-x_1))

bernoulli = function(y, pix) {
  -y * log(pix) - (1 - y) * log(1 - pix)
}

x_2 <- seq(0L, 1L, by = 0.001)
df <- data.frame(x = x_2, y = 1L, pi = bernoulli(1L, x_2))
df <- rbind(df, data.frame(x = x_2, y = 0L, pi = bernoulli(0L, x_2)))
df$y <- as.factor(df$y)

# PLOTS ------------------------------------------------------------------------

p_1 <- ggplot2::qplot(
  x_1, 
  y, 
  geom = "line",
  xlab = expression(r = yf(x)),
  ylab = expression(L(y, f(x))))

p_1 <- p_1 + 
  ggplot2::annotate(
    "text",
    x = 2L,
    y = 2L,
    label = bquote(L(y, f(x)) ~ "=" ~ ln(1 + exp(-yf(x)))),
    size = 7L)

p_1 <- p_1 + theme_bw()
p_1 <- p_1 + theme(text = element_text(size = 20L))

ggplot2::ggsave("../figure/plot_bernoulli_plusmin_encoding.png", p_1)

p_2 <- ggplot2::ggplot(data = df, aes(x = x, y = pi, color = y)) + 
  geom_line() + 
  xlab(expression(pi(x))) + 
  ylab(expression(L(y, pi(x)))) + 
  theme_bw() +
  theme(text = element_text(size = 20L)) +
  scale_color_viridis_d(end = 0.9)

ggplot2::ggsave("../figure/plot_bernoulli_prob.png", p_2)

