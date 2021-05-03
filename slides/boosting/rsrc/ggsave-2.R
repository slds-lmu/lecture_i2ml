

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

############################################### GRADIENT BOOSTING ILLUSTRATION - 1

nsim = 50L

set.seed(31415)
x = seq(0, 10, length.out = nsim)
y = 4 + 3 * x + 5 * sin(x) + rnorm(nsim, 2)


layout(1)
# 1. plot to visualize data without scaling
png("figure_man/illustration_data_normal.png", width = 350, height = 250)
plot(x = x, y = y, xlab = "Feature x", ylab = "Target y")
dev.off()

# 2. plot to visualize data with scaling
y = scale(y)
png("figure_man/illustration_data_normal_scaled.png", width = 350, height = 250)
plot(x = x, y = y, xlab = "Feature x", ylab = "Target y")
dev.off()

##############################################

source("rsrc/boosting_animation_gam.R")

basisTrafo = function (x) {
  margin = 0.1 * (max(x) - min(x))
  splines::splineDesign(knots = seq(min(x) - margin, max(x) + margin, length.out = 40), x = x)
}




# for (nboost in boosting_iters) {
#   cat("\\begin{vbframe}{Gradient boosting illustration - 1}\n")
#   plotLineaBoosting(x, y, nboost, 0.2, distribution = "gaussian", basis_fun = basisTrafo)
#   if (nboost > 1)
#     cat("\\addtocounter{framenumber}{-1}\n\n")
#   cat("\\end{vbframe}\n\n")
# }

plot_boosting = function(loss, eps, distribution, basis_fun, x, y, boosting_iters, alpha = 0.2){
  for (nboost in boosting_iters) {
    
    name = paste0("figure_man/illustration_",eps,"_",loss,"_",nboost,".png")
    png(name, width = 550, height = 270)
    plotLineaBoosting(x, y, nboost, alpha,  distribution = distribution, basis_fun = basis_fun)
    dev.off()
    
  }
}

# L2  and L1 examples
boosting_iters = c(1,2,3,5,10,100)
plot_boosting("L2", eps = "normal", distribution = "gaussian", basis_fun = basisTrafo, x = x, y = y, boosting_iters)
plot_boosting("L1", eps = "normal", distribution = "laplace", basis_fun = basisTrafo, x = x, y = y, boosting_iters)

# Huber loss examples
boosting_iters = 5
# plot for huber loss 0.5
plot_boosting("huber0.5", eps = "normal", distribution = "huber", basis_fun = basisTrafo, x = x, y = y, boosting_iters, alpha = 0.5)

# plot for huber loss 1
plot_boosting("huber1", eps = "normal", distribution = "huber", basis_fun = basisTrafo, x = x, y = y, boosting_iters, alpha = 1)

# plot for huber loss 10
plot_boosting("huber2", eps = "normal", distribution = "huber", basis_fun = basisTrafo, x = x, y = y, boosting_iters, alpha = 2)




# linear model
basisTrafo_linear =  function (x) cbind(1, x)

# L2  and L1 examples
boosting_iters = c(1,2,3,5,10)
plot_boosting("L2_linear", eps = "normal", distribution = "gaussian", basis_fun = basisTrafo_linear, x = x, y = y, boosting_iters)
plot_boosting("L1_linear", eps = "normal", distribution = "laplace", basis_fun = basisTrafo_linear, x = x, y = y, boosting_iters)



# examples with outliers and gam:
set.seed(31452)
y = 4 + 3 * x + 5 * sin(x) + rt(nsim, 1)
y = scale(y)

# L2  and L1 examples
boosting_iters = c(1,2,3,10)
plot_boosting("L2", eps = "tdist", distribution = "gaussian", basis_fun = basisTrafo, x = x, y = y, boosting_iters)
plot_boosting("L1", eps = "tdist", distribution = "laplace", basis_fun = basisTrafo, x = x, y = y, boosting_iters)






