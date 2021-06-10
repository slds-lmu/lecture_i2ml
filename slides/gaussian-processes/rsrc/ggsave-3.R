
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


n = 100
x = seq(-2, 2, length.out = n)
K = matrix(0, n, n)
l = c(0.1, 1, 10)

plots = list()

for (k in 1:length(l)) {
  for (i in 1:n) {
    for (j in 1:n) {
      K[i, j] = exp(- 1/2 * (abs(x[i] - x[j]))^2 / l[k])
    }
  }
  
  df = data.frame(x = x)
  
  for (i in 1:10) {
    df[, i + 1] = as.vector(mvtnorm::rmvnorm(1, sigma = K))
  }
  
  df.m = melt(df, id.vars = "x")
  
  p = ggplot(data = df.m, aes(x = x, y = value, colour = variable)) + geom_line() + theme_bw()
  p = p + xlab("x") + ylab("f(x)") + ylim(c(-5, 5))
  p = p + theme(legend.position = "none")
  
  plots[[k]] = p
}
do.call("grid.arrange", list(grobs = plots, ncol = 3))
#######################################################