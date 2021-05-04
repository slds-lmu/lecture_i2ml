
library(mlr)
library(mlbench)
library(ggplot2)
library(gridExtra)
library(mvtnorm)


n <- 400
par(mfrow = c(1,6), mar = c(2, 2, 2, 0.5))
x = runif(n, -1, 1)
y = 4 * (x^2 - 1/2)^2 + runif(n, -1, 1)/3
plot(cbind(x,y), xlab = "x", ylab = "y")

xnorm = rnorm(n, 0, 0.5)
y = runif(n, -(1-abs(xnorm)), 1-abs(xnorm))
plot(cbind(xnorm,y), xlab = "x", ylab = "y", xlim = c(-1, 1))

y = 2*x^2 + runif(n, -1, 1)
plot(cbind(x,y), xlab = "x", ylab = "y")

y = (x^2 + runif(n, 0, 1/2)) * sample(seq(-1, 1, 2), n, replace = TRUE)
plot(cbind(x,y), xlab = "x", ylab = "y")

y = cos(x*pi) + rnorm(n, 0, 1/8)
x = sin(x*pi) + rnorm(n, 0, 1/8)
plot(cbind(x,y), xlab = "x", ylab = "y")

xy1 = rmvnorm(n/4, c( 3,  3))
xy2 = rmvnorm(n/4, c(-3,  3))
xy3 = rmvnorm(n/4, c(-3, -3))
xy4 = rmvnorm(n/4, c( 3, -3))
plot(rbind(xy1, xy2, xy3, xy4), xlab = "x", ylab = "y")

############################################################################