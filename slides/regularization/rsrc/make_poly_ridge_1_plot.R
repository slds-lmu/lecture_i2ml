# ------------------------------------------------------------------------------
# FIG: POLYNOMIAL RIDGE 1
# ------------------------------------------------------------------------------

library(ggplot2)
library(viridis)

theme_set(theme_minimal())

# DATA -------------------------------------------------------------------------

source("ridge_polynomial_reg.R")

set.seed(314259)
f <- function (x) {
  return (5 + 2 * x + 10 * x^2 - 2 * x^3)
}

x <- runif(40, -2, 5)
y <- f(x) + rnorm(length(x), 0, 10)

x.true <- seq(-2, 5, length.out = 400)
y.true <- f(x.true)
df <- data.frame(x = x.true, y = y.true)

lambda.vec <- 0

# PLOTS ------------------------------------------------------------------------

p <- plotRidge(x, y, lambda.vec, baseTrafo, degree = 10) +
  geom_line(data = df, aes(x = x, y = y), color = "red", size = 1) +
  xlab("x") + ylab("f(x)") +
  theme(plot.title = element_text(size = 15)) +
  scale_color_viridis(end = 0.9, discrete = TRUE)

ggsave("../figure/poly_ridge_1.png", plot = p, width = 6, height = 2)
