# ------------------------------------------------------------------------------
# FIG: MANIFOLD
# ------------------------------------------------------------------------------

library(scatterplot3d)
source("helpers/constants.R")

# DATA -------------------------------------------------------------------------
n <- 10000
phi <- 1.5 * 2* pi* runif(n)

x <- phi*sin(phi)
y <- phi*cos(phi)
z <- runif(n)

# PLOTS ------------------------------------------------------------------------
png(filename = "../figure/manifold_plot.png", width = 8, height = 3, units = "in", res = 300)
scatterplot3d(data.frame(x, y, z), angle = 300, color = phi, axis = FALSE)
dev.off()