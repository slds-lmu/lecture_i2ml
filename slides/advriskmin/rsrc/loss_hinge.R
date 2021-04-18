# ------------------------------------------------------------------------------
# FIG: HINGE LOSS
# ------------------------------------------------------------------------------

# DATA -------------------------------------------------------------------------

x <- seq(-2L, 2L, by = 0.01)
l_01 <- as.numeric(x < 0L)
l_hinge <- ifelse(x < 1L, 1L - x, 0L)

df <- tidyr::gather(data.frame(x, l_hinge, l_01), "loss", "value", -x)

# PLOTS ------------------------------------------------------------------------

p <- ggplot2::ggplot(
  df,
  aes(x = x, y = value, col = loss)) +
  geom_line(size = 1.2) +
  scale_color_viridis_d(
    end = 0.9,
    name = "loss",
    labels = c("0-1", "hinge"),
    direction = -1L) + 
  xlab(expression(r = yf(x))) +
  ylab(expression(L(y, f(x)))) +
  theme_minimal() + 
  theme(text = element_text(size = 30L))

ggplot2::ggsave("../figure/plot_loss_hinge.png", p, height = 4L, width = 12L)

