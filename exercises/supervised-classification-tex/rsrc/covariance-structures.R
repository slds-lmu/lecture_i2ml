# Used in: ex_rnw/ex_covariance-structures.Rnw, ex_rnw/sol_covariance-structures.Rnw
#
# Five 2D data sets with two Gaussian classes each, differing in their covariance structure.
# plot_cov_cases(titles) returns one panel per case with the sampled points and the
# 90% (solid) and 50% (dashed) normal ellipses per class. The data are sampled once with a
# fixed seed, so exercise and solution show the same points.

library(MASS)
library(ggplot2)
library(patchwork)

set.seed(42)

# class means and covariance matrices per case
cov_cases = list(
  list(mu_1 = c(-4, 0), sigma_1 = matrix(c(2, 1, 1, 2), nrow = 2L),
    mu_2 = c(4, 0), sigma_2 = matrix(c(2, 1, 1, 2), nrow = 2L)),
  list(mu_1 = c(-4, 1.4), sigma_1 = matrix(c(3, 2, 2, 3), nrow = 2L),
    mu_2 = c(4, 0.4), sigma_2 = matrix(c(3, -2, -2, 2), nrow = 2L)),
  list(mu_1 = c(-4, 0), sigma_1 = diag(c(1, 1)), mu_2 = c(4, 1), sigma_2 = diag(c(1, 1))),
  list(mu_1 = c(-4, 0), sigma_1 = diag(c(1, 1)), mu_2 = c(4, 0), sigma_2 = diag(c(3, 3))),
  list(mu_1 = c(-4, 0), sigma_1 = diag(c(1, 2)), mu_2 = c(4, 0), sigma_2 = diag(c(3, 1)))
)

# n points per class
sample_case = function(case, n = 750L) {
  points_1 = mvrnorm(n, mu = case$mu_1, Sigma = case$sigma_1)
  points_2 = mvrnorm(n, mu = case$mu_2, Sigma = case$sigma_2)
  points = rbind(points_1, points_2)
  data.frame(x1 = points[, 1], x2 = points[, 2], class = rep(c("1", "2"), each = n))
}
cov_data = lapply(cov_cases, sample_case)

plot_case = function(data, title) {
  ggplot(data, aes(x1, x2, colour = class)) +
    geom_point(alpha = 0.1, size = 0.6, stroke = 0) +
    stat_ellipse(type = "norm", level = 0.9, linewidth = 0.9) +
    stat_ellipse(type = "norm", level = 0.5, linetype = "dashed", linewidth = 0.7) +
    coord_equal() +
    labs(x = expression(x[1]), y = expression(x[2]), title = title) +
    theme_minimal(base_size = 11) +
    theme(legend.position = "none", plot.title = element_text(hjust = 0.5, face = "bold"))
}

plot_cov_cases = function(titles) Map(plot_case, cov_data, titles)
