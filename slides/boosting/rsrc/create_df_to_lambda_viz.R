# devtools::install_github("schalkdaniel/compboostSplines")

nsim = 100

# Sample data:
x = sort(runif(nsim, 0, 10))
y = 2 * sin(x) + rnorm(nsim, 0, 0.5)

# Calculate knots of given x values:
knots = compboostSplines:::createKnots(values = x, n_knots = 20, degree = 3)

# Create basis using that knots:
basis = compboostSplines:::createSplineBasis(values = x, degree = 3, knots = knots)

# Polynomial regression using b-splines:
beta = solve(t(basis) %*% basis) %*% t(basis) %*% y

# Get penalty matrix:
K = compboostSplines:::penaltyMat(ncol(basis), differences = 2)


# Lets visualize the curves:

library(ggplot2)
library(ggthemes)

# We use the basis and penalty matrix from above and specify 2 and 4 degrees of freedom:
penalty_df2 = compboostSplines:::demmlerReinsch(t(basis) %*% basis, K, 2)
#> [1] 42751174892
penalty_df4 = compboostSplines:::demmlerReinsch(t(basis) %*% basis, K, 4)
#> [1] 418.8

# This is now used for a new estimator:
beta_df2 = solve(t(basis) %*% basis + penalty_df2 * K) %*% t(basis) %*% y
beta_df4 = solve(t(basis) %*% basis + penalty_df4 * K) %*% t(basis) %*% y

plot_df = data.frame(
  x = x,
  y = y
)

types = c("B-Spline", "P-Spline with 2 df", "P-Spline with 4 df")
spline_df = data.frame(
  "Spline" = rep(types, each = nsim),
  "x" = rep(x, length(types)),
  "y" = c(basis %*% beta, basis %*% beta_df2, basis %*% beta_df4)
)

ggplot() + geom_point(data = plot_df, mapping = aes(x = x, y = y)) +
  geom_line(data = spline_df, mapping = aes(x = x, y = y, color = Spline))

# ggsave("df_to_lambda.pdf", width = 8, height = 4)