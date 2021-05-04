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

############################################################################

set.seed(123)
n = 100
x = seq(-2, 2, length.out = n)

K = squared.exp(x, x.obs, l = 0.4)
K.xx = K[(n + 1):nrow(K), (n + 1):nrow(K)]
K.xxs = K[1:n, (n + 1):nrow(K)]
K.xsxs = K[1:n, 1:n]

df = data.frame(x = x)

# Drawing from Gaussian process Prior
df[, 2] = as.vector(mvtnorm::rmvnorm(1, sigma = K.xsxs))
df[, 3] = 1 / (1 + exp(- df[, 2]))

p1 = ggplot(data = df, aes(x = x, y = V2)) + geom_line() + theme_bw()
p1 = p1 + xlab("x") + ylab("f(x)") + ylim(c(-3, 3))
p1 = p1 + theme(legend.position = "none") + ggtitle("Function drawn from a GP prior")

p2 = ggplot(data = df, aes(x = x, y = V3)) + geom_line() + theme_bw()
p2 = p2 + xlab("x") + ylab(expression(s(f(x)))) + ylim(c(0, 1))
p2 = p2 + theme(legend.position = "none") + ggtitle("Function transformed into probs")

grid.arrange(p1, p2, nrow = 1)


############################################################################

hinge = function(r) {
  pmax(0, 1 - r)
}

x = seq(-2, 2, by = 0.01); y = exp(-x)
df = data.frame(x = x, Logistic = y, Hinge = hinge(x))
df = melt(df, id.vars = "x")

p = ggplot(data = df) + geom_line(aes(x = x, y = value, color = variable)) + labs(color = "")
p