

library(qrmix)
library(mlr)
library(quantreg)
library(reshape2)
library(ggplot2)

xx = seq(-2, 2, by = 0.01); 
yy = xx^2
plot(xx, yy, type = "l", xlab = "y - f(x)", ylab = "L(y, f(x))")
points(1, 1, col = "red")
lines(x = c(1, 1), y = c(0, 1), col = "red")
points(xx, 2 * xx - 1, type = "l", col = "red")