
library(knitr)
library(mlr)
library(mlrMBO)
library(ggplot2)
library(gridExtra)
library(reshape2)
library(kernlab)
library(mvtnorm)
library(gptk)
library(smoof)

###############################################################

f = function(x) sin(20 * x + 0.3)
root.f = function(k) (pi * 2 * k - 0.3) / 20

x = seq(0, 1, by = 0.01)
y = f(x)
upcross = c(root.f(1), root.f(2), root.f(3))

p = ggplot() + geom_line(data = data.frame(x = x, y = y), aes(x = x, y = y))
p = p + geom_point(data = data.frame(x = upcross, y = 0), aes(x = x, y = y), color = "red", size = 2)
p = p + theme_bw()
p 

