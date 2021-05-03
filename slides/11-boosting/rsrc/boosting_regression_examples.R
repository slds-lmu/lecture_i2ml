################# SLIDES BOOSTING REGRESSION ILLUSTRATIONS

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
boosting_iters = c(1,2,3,10)
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
boosting_iters = c(1,2,3,10)
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






