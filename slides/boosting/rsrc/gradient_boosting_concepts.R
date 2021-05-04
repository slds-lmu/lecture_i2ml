

library(knitr)
library(ggplot2)
library(randomForest)
library(colorspace)
library(mlr)
library(mboost)
library(mlbench)


################################################## GRADIENT BOOSTING

library(gridExtra)
set.seed(8)
n = 15
x = sort(runif(n, 0, 18))
y = sin(x / 2) + rnorm(length(x), 0, sd = 0.1)

y_lim = c(-1.3,1.3)

pl_data = data.frame(x=x, y=y)
pl1 = ggplot(pl_data, aes(x=x, y=y)) +
  geom_point() +
  ylim(y_lim) +
  ylab(expression("Target"~y)) +
  xlab(expression("Feature"~x))

pred_data = data.frame(x=x, y=mean(y), c="1")

pl2 = pl1 + 
  geom_line(data=pred_data, aes(x=x, y=y, colour=c), lty = "dotted") +
  geom_point(data=pred_data, aes(x=x, y=y, colour=c))+
  theme(legend.position = "none")

ggsave("figure_man/gradient-boosting.png", pl2)

res = y #- mean(y)
res_data = data.frame(x = x, y = res)
pl_arrow = data.frame(x = x, x_end=x, y = res-0.15, y_end=res+0.15)
pl3 = ggplot(res_data, aes(x=x, y=y)) +
  geom_point(col="red") +
  geom_line(lty = "dotted", col="red") +
  geom_segment(data=pl_arrow, aes(x=x, y=y, xend=x, yend=y_end),
               alpha=0.2, arrow=arrow(ends = "both", length = unit(0.13, "inches"))) +
  ylim(y_lim) +
  ylab(expression("Target"~y)) +
  xlab(expression("Feature"~x))
ggsave("figure_man/forward-stagewise-expl.png", pl3)

################################################ pseudo-residuals.
theme_set(theme_minimal())
source("rsrc/pseudo_boosting.R")
coefs = pseudo_boosting(y, 3)
p1 = plot_pseudo_boosting_step(coefs, c(1,2))


source("rsrc/pseudo_boosting.R")
coefs = pseudo_boosting(y, 3)
p2 = plot_pseudo_boosting_step(coefs, c(2,3))

ggsave("figure_man/pseudo-resi01.png", p1)
ggsave("figure_man/pseudo-resi02.png", p2)

###############################################

source("rsrc/boosting_idea.R")
coefs = boosting(x, y, nboost = 4, learning_rate = 0.4, basis_fun = bTrafo)

p3 = plot_splines_boosting_step(coefs, its=c(0,1))
p4 = plot_splines_boosting_step(coefs, its=c(1,2))
p5 = plot_splines_boosting_step(coefs, its=c(2,3))

ggsave("figure_man/gradient-boosting01.png", p3)
ggsave("figure_man/gradient-boosting02.png", p4)
ggsave("figure_man/gradient-boosting03.png", p5)

