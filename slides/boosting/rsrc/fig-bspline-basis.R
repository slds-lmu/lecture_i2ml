# ------------------------------------------------------------------------------
# FIG: B-SPLINE BASIS
# ------------------------------------------------------------------------------

# Purpose: visualize additive structure of B-splines

# DATA -------------------------------------------------------------------------

x <- seq(0L, 1L, length.out = 100L)
df <- 3L

splines <- data.table::data.table(
  x, 
  splines::bs(x, df = df, knots = c(0L, 1/3, 2/3, 1L)))

data.table::setnames(
  splines, 
  c("x", sprintf("b_%s", seq_len(ncol(splines) - 1L))))

splines_long <- data.table::melt(
  splines,
  id = "x",
  measure = sprintf("b_%s", seq_len(ncol(splines) - 1L)))

splines_weighted <- data.table::copy(splines)[, `:=` (
  b_2 = 0.7 * b_2,
  b_3 = 1.1 * b_3,
  b_4 = 0.3 * b_4,
  b_5 = 0.2 * b_5,
  b_6 = 0.8 * b_6,
  b_7 = 0.4 * b_7)
  ][, y := sum(.SD),
    .SDcols = sprintf("b_%s", seq_len(ncol(splines) - 1L)),
    by = seq_len(nrow(splines))]

splines_long_weighted <- data.table::melt(
  splines_weighted,
  id = c("x", "y"),
  measure = sprintf("b_%s", seq_len(ncol(splines) - 1L)))

# PLOTS ------------------------------------------------------------------------

p_1 <- ggplot2::ggplot(
  splines_long, 
  ggplot2::aes(x = x, y = value, col = variable)) +
  ggplot2::geom_line() +
  ggplot2::ggtitle("cubic B-spline basis") +
  ggplot2::theme_minimal() +
  ggplot2::scale_color_viridis_d(end = 0.8) +
  ggplot2::guides(col = FALSE) +
  ggplot2::xlab("") + 
  ggplot2::ylab("")

p_2 <- ggplot2::ggplot(
  splines_long_weighted, 
  ggplot2::aes(x = x, y = value, col = variable)) +
  ggplot2::geom_line() +
  ggplot2::theme_minimal() +
  ggplot2::scale_color_viridis_d(end = 0.8) +
  ggplot2::guides(col = FALSE) + 
  ggplot2::ggtitle("cubic B-spline basis weighted with coefficients") +
  ggplot2::xlab("") + 
  ggplot2::ylab("")

p_3 <- ggplot2::ggplot(
  splines_long_weighted, 
  ggplot2::aes(x = x, y = y)) +
  ggplot2::geom_line() +
  ggplot2::theme_minimal() +
  ggplot2::ggtitle("sum of weighted cubic B-splines") + 
  ggplot2::xlab("") + 
  ggplot2::ylab("")

p <- gridExtra::grid.arrange(
  p_1, p_2, p_3, layout_matrix = rbind(c(1L, 2L), c(3L, 3L)))

ggplot2::ggsave("../figure/bspline-basis.png", p, height = 4.5, width = 10L)
