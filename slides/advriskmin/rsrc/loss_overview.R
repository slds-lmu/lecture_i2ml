# ------------------------------------------------------------------------------
# FIG: LOSSES OVERVIEW
# ------------------------------------------------------------------------------

# DATA -------------------------------------------------------------------------

x <- seq(-2L, 2L, length.out = 800L)

huber <- Huber(x, c = 2L)
log_bar <- log_barrier(x, a = 1L)
cau <- cauchy(x, c = 1L)
lcosh <- logcosh(x)

epsilon <- 0.8
eps_ins <- ifelse(
  x < -epsilon,
  abs(x) - epsilon,
  ifelse(
    x < epsilon,
    0L,
    x - epsilon))

alpha <- 0.7
quant <- ifelse(
  x < 0L,
  (1 - alpha) * abs(x),
  alpha * x)

df <- tidyr::gather(
  data.frame(x, huber, log_bar, cau, eps_ins, quant, lcosh),
  "loss",
  "value",
  -x)

# PLOTS ------------------------------------------------------------------------

p <- ggplot2::ggplot(df, aes(x = x, y = value, color = loss)) + 
  ggplot2::geom_line(size = 1.1) +
  ggplot2::scale_color_viridis_d(
    end = 0.9,
    name = "",
    labels = c(
      "Cauchy",
      "Epsilon-ins (eps = 0.8)",
      "Huber (c = 1)",
      "Log-cosine",
      "Log-barrier (eps = 1)",
      "Quant (alpha = 0.7)")) +
  ggplot2::guides(color = guide_legend(ncol = 2)) +
  ggplot2::ylim(c(0L, 2L)) +
  ggplot2::xlab(bquote(y - f(x))) +
  ggplot2::ylab(bquote(L(y, f(x)))) +
  ggplot2::theme_bw() +
  ggplot2::theme(
    text = element_text(size = 20L),
    legend.position = "bottom")

ggplot2::ggsave("../figure/plot_loss_overview.png", p, width = 6L, height = 4L)
