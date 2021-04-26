# ------------------------------------------------------------------------------
# FIG: HINGE LOSS
# ------------------------------------------------------------------------------

library(ggplot2)

# DATA -------------------------------------------------------------------------

x <- seq(-1L, 2L, by = 0.01)
l_01 <- as.numeric(x < 0L)
l_hinge <- ifelse(x < 1L, 1L - x, 0L)
l_hinge_squared <- ifelse(x < 1L, (1L - x)^2, 0L)

df <- tidyr::gather(
  data.frame(x, l_hinge_squared, l_hinge, l_01), 
  "loss", 
  "value", 
  -x)

# PLOTS ------------------------------------------------------------------------

p_1 <- ggplot2::ggplot(
  df[df$loss != "l_hinge_squared", ],
  aes(x = x, y = value, col = loss)) +
  geom_line(size = 1.2) +
  scale_color_viridis_d(
    end = 0.9,
    name = "Loss",
    labels = c("0-1", "hinge"),
    direction = -1L) + 
  xlab(expression(yf(x))) +
  ylab(expression(L(y, f(x)))) +
  theme_minimal() + 
  theme(text = element_text(size = 30L))

ggplot2::ggsave("../figure/plot_loss_hinge.png", p_1, height = 4L, width = 12L)

p_2 <- ggplot2::ggplot(
  df,
  aes(x = x, y = value, col = loss)) +
  geom_line(size = 1.2) +
  scale_color_viridis_d(
    end = 0.9,
    name = "Loss",
    labels = c("0-1", "hinge", "squared hinge"),
    direction = -1L) + 
  xlab(expression(r = yf(x))) +
  ylab(expression(L(y, f(x)))) +
  theme_minimal() + 
  theme(text = element_text(size = 30L))

ggplot2::ggsave(
  "../figure/plot_loss_hinge_squared.png", 
  p_2, 
  height = 6L, 
  width = 12L)
