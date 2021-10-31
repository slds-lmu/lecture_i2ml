# ------------------------------------------------------------------------------
# FIG: LASSO, RIDGE & ELASTIC NET PENALTY
# ------------------------------------------------------------------------------

# Purpose: visualize penalties for 2D example

library(ggplot2)
library(data.table)

# DATA -------------------------------------------------------------------------

x <- seq(-1L, 1L, length.out = 1000L)
dt <- data.table::as.data.table(expand.grid(x = x, y = x))

dt[, `:=` (
  lasso = 1L - abs(x) - abs(y),
  ridge = 1L - x^2 - y^2,
  enet = 1L - (0.5 * abs(x) + 0.5 * x^2) - (0.5 * abs(y) + 0.5 * y^2))]

dt_long <- data.table::melt(
  dt, 
  id = c("x", "y"),
  measure = c("lasso", "ridge", "enet"))

# PLOT -------------------------------------------------------------------------

p <- ggplot2::ggplot(
  dt_long, 
  ggplot2::aes(x = x, y = y, z = value, col = variable)) +
  ggplot2::geom_contour(bins = 2L) +
  ggplot2::theme_minimal() +
  ggplot2::scale_color_viridis_d(
    end = 0.85,
    name = "penalty",
    labels = c("L1 (Lasso)", "L2 (Ridge)", "Elastic Net")) +
  ggplot2::xlab(expr(theta[1])) +
  ggplot2::ylab(expr(theta[2])) +
  ggplot2::theme(text = ggplot2::element_text(size = 20L)) +
  ggplot2::coord_fixed(ratio = 1L)

ggplot2::ggsave("../figure/lasso_ridge_enet_2d.png", p, width = 6L)
