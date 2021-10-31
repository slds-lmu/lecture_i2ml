library(plotly)
library(scales)
library(raster)
library(akima)
library(numDeriv)
library(gridExtra)


# 0 - Plotting Functions 

plotLinearModel = function(opt.path, X, y, iteration = 1) {


  data = data.frame(cbind(X, y))
  
  p1 = ggplot(data = data, aes(x = x, y = y)) + geom_point()

  if (ncol(X) == 1) {
    # p1 = p1 + geom_hline(yintercept = theta.opt[1], colour = "green")
    p1 = p1 + geom_hline(data = opt.path[1:iteration, ], aes(yintercept = theta1), color = "black", alpha = 0.5)    
    p1 = p1 + geom_hline(data = opt.path[iteration, ], aes(yintercept = theta1), color = "orange", size = 1.5)    
  }

  if (ncol(X) == 2) {
    # p1 = p1 + geom_abline(data = data.frame(), intercept = theta.opt[1], slope = theta.opt[2], colour = "green")
    p1 = p1 + geom_abline(data = opt.path[1:iteration, ], aes(intercept = theta1, slope = theta2), color = "black", alpha = 0.5)
    p1 = p1 + geom_abline(data = opt.path[iteration, ], aes(intercept = theta1, slope = theta2), color = "orange", size = 1.5)
  }

  p1 = p1 + theme_bw() + ggtitle(paste("Iteration", iteration))

  return(p1)

}

plotRisk = function(opt.path, risk, theta_lower, theta_upper, iteration = 1) {

  if (ncol(opt.path) == 3) {

    theta1 = seq(theta_lower[1], theta_upper[1], length.out = 50)
    theta2 = seq(theta_lower[2], theta_upper[2], length.out = 50)
    
    df = expand.grid(theta1, theta2)

    z = apply(df, 1, risk)

    plotdf = cbind.data.frame(df, z) 
    names(plotdf) = c("theta1", "theta2", "z") 

    p = ggplot() +
      geom_raster(data = plotdf, aes(x = theta1, y = theta2, fill = z),
                  show.legend = TRUE) +
      # scale_fill_gradientn(colours=c("#FFFFFF","#726A6A")) +
      geom_contour(data = plotdf, aes(x = theta1, y = theta2, z = z), alpha = 0.5, size = 0.5) 
    
    p = p + geom_point(data = opt.path[1:iteration, ], aes(x = theta1, y = theta2), inherit.aes = FALSE) +
       geom_point(data = opt.path[iteration, ], aes(x = theta1, y = theta2), colour = "orange") +
      xlab(expression(theta[0])) + ylab(expression(theta[1])) +
      ggtitle(paste("Iteration", iteration)) +
      theme(plot.title = element_text(hjust = .5)) +
      theme_bw() +
      guides(fill = guide_legend(title = expression(R[emp])))

  }  
  
  if (ncol(opt.path) == 2) {
    
    theta1 = seq(theta_lower[1], theta_upper[1], length.out = 50)
  
    z = sapply(theta1, risk)

    plotdf = data.frame(theta1 = theta1, z = z) 

    p = ggplot() + geom_line(data = plotdf, aes(x = theta1, y = z))    
    p = p + geom_point(data = opt.path[1:iteration, ], aes(x = theta1, y = risk), inherit.aes = FALSE) 
    p = p + geom_point(data = opt.path[iteration, ], aes(x = theta1, y = risk), inherit.aes = FALSE, colour = "orange") 
    p = p + xlab(expression(theta[0])) + ylab(expression(R[emp])) +
      ggtitle(paste("Iteration", iteration)) 
    p = p + theme(plot.title = element_text(hjust = .5)) + theme_bw() 

  }

  return(p)
}


gradDescent = function(risk, theta0, max.iter = 100, step.size = 0.00005,
                       stop.grad = .Machine$double.eps) {
  

  optpath.x = list()
  optpath.y = c()
  
  optpath.x[[1]] = theta0
  optpath.y = risk(theta0)
  
  for (i in 2:max.iter) {
    
    nabla = grad(risk, x = optpath.x[[i - 1]])
  
    # Check if stop-criterion already reached
    if (all(abs(nabla) < stop.grad)) {
      i = i - 1
      break
    }
    
    # Determine new point by moving into negative grad direction
    theta_new = optpath.x[[i - 1]] - step.size * nabla
    optpath.x[[i]] = theta_new
    optpath.y = c(optpath.y, risk(theta_new))
  }
  
  # Return results
  opt.path = do.call(rbind, optpath.x)
  opt.path = as.data.frame(opt.path)
  names(opt.path) = paste0("theta", 1:(ncol(opt.path)))

  opt.path$risk = optpath.y 

  return(list(opt.path = opt.path, niter = i))
}


# 1 - Create Plots  

source("rsrc/loss_functions.R")

# available loss functions
lossfuns = list(L1 = L1, L2 = L2, quant = quant, huber = huber)

# risk function 
risk = function(theta, f, X, y, loss = c("L2")) {
      
      L = get(loss, lossfuns) 
      r = y - apply(X, 1, function(x) f(x, theta))
      g = sum(sapply(r, L))
         
  return(as.numeric(g))

}

# linear model 
f = function(x, theta) {
  x %*% theta
}


# 1A - constant model 

# define the data
n = 100
x = seq(0, 10, length.out = n)
y = 0.3 + rnorm(n)

df = data.frame(y = y, x0 = 1)

X = as.matrix(df[, c("x0")])

risk_limo = function(x) risk(x, f, X, y, loss = "huber")


# perform gradient descent
theta0 = 1
opt.path = gradDescent(risk_limo, theta0 = theta0, max.iter = 20, step.size = 0.01)$opt.path

# "true" optimum
theta.opt = optimize(risk_limo, interval = c(-5, 5))$minimum

for (iter in 1:4) {
  p1 = plotLinearModel(opt.path, X, y, iteration = iter)
  p2 = plotRisk(opt.path, risk_limo, theta_lower = - 0.5, theta_upper = 1.5, iteration = iter)

  ggsave(paste0("figure_man/empirical_risk_plot_constant_", iter, ".pdf"), grid.arrange(p1, p2, nrow = 1), width = 7, height = 4)
}


# 1b - Linear model with one covariable

# define the data
n = 100
x = seq(0, 10, length.out = n)
y = 0.3 + x + rnorm(n)

df = data.frame(y = y, x0 = 1, x1 = x)

X = as.matrix(df[, c("x0", "x1")])

# perform gradient descent

theta0 = c(0.1, 0.7)
opt.path = gradDescent(risk_limo, theta0 = theta0, max.iter = 100, step.size = 0.001)$opt.path

# "true" optimum
theta.opt = optimize(risk_limo, interval = c(-5, 5))$minimum

for (iter in 1:4) {
  p1 = plotLinearModel(opt.path, X, y, iteration = iter)
  p2 = plotRisk(opt.path, risk_limo, theta_lower = c(-0.5, 0.5), theta_upper = c(1.5, 1.5), iteration = iter)

  ggsave(paste0("figure_man/empirical_risk_plot_linear_", iter, ".pdf"), grid.arrange(p1, p2, nrow = 1), width = 7, height = 4)
}







# #3 Plot emprirical risk in 2-d or 3-d space
# plotEmpRisk = function(f, theta1Lower, theta1Upper, theta2Lower, theta2Upper, thetastart, 
#                     ntheta = 30L, y, x, loss, mode = c("2d", "3d"), step.size = 0.005) {
  
#   col = "red"
  
#   # Generate grid with specfied dimensions and data.frame for plot
#   theta1 = seq(theta1Lower, theta1Upper, length.out = ntheta)
#   theta2 = seq(theta2Lower, theta2Upper, length.out = ntheta)
  
#   #if(!(ncol(optimResult) == length(theta)))  stop("Theta values of optimization and provided thetas do not match")
  
  
#   df = expand.grid(theta1, theta2)
#   z = apply(df, 1, f, y = y, x = x, loss = loss)
#   plotdf = cbind.data.frame(df, z) 
#   names(plotdf) = c("theta1", "theta2", "z") 
  
#   optimpoints = gradDescent(f, thetastart, y = y, xobs = data.frame(x[,1], x[,2]), 
#                             loss = loss, step.size = step.size)
  
#   plotpointsdf = optimpoints$results
  
 
#   # Generate contour plot and add steps of descent procedure as points
#   if (mode == "2d") {
#   plot = ggplot() +
#     geom_raster(data = plotdf, aes(x = theta1, y = theta2, fill = z), show.legend = FALSE) +
#     geom_contour(data = plotdf, aes(x = theta1, y = theta2, z = z), colour = "white", alpha = 0.5, size = 0.5) +
#     geom_point(data = plotpointsdf, aes(x = theta1, y = theta2), colour = "red",
#                alpha = .5) +
#     geom_path(data = plotpointsdf, aes(x = theta1, y = theta2), colour = "red") +
#     xlab(expression(theta[1])) + ylab(expression(theta[2])) +
#     theme(plot.title = element_text(hjust = .5)) +
#     theme(legend.title = element_blank())
  
#   } else {
    
#     surface = interp(x = plotdf$theta1, y = plotdf$theta2, z = plotdf$z)
    
#     plot = plot_ly() %>%
#       add_surface(x = surface$x, y = surface$y, z = surface$z,
#                   colorscale = list(c(0,1), c("lightgrey", "lightblue"))) %>%
#       layout(
#         scene = list(
#           xaxis = list(title = "theta<sub>1</sub>"),
#           yaxis = list(title = "theta<sub>2</sub>"),
#           zaxis = list(title = "Risk"),
#           color = c("grey")
#         )) %>%
#       add_trace(data = plotpointsdf, type = "scatter3d", x = ~theta2, y = ~theta1, z = ~y,
#       mode = "markers", marker = list(size = 5)) %>%
#       add_annotations(text = "", xref="paper", yref="paper", x=1.05, xanchor="left",
#                       y=1, yanchor="bottom", legendtitle=FALSE, showarrow=FALSE)
#   }
  
#   return(plot)
# }

# #4 Make plots (example)

# # 3d plot with L2 loss, plotted space [-5,5]x[-5,5]. optimization starts at point (4,4)
# plotEmpRisk(g, -5, 5, -5, 5, 30, df$y, data.frame(df$x1, df$x2), loss = "huber", mode = "3d", thetastart = c(4,4),
#          step.size = 0.001)

# # 2d plot with L2 loss, plotted space [-5,5]x[-5,5]. optimization starts at point (4,4)
# plotEmpRisk(g, -5, 5, -5, 5, 30, df$y, data.frame(df$x1, df$x2), loss = "L1", mode = "2d", thetastart = c(4,4),
#          step.size = 0.001)

# plotEmpRisk(g, -5, 5, -5, 5, 30, df$y, data.frame(df$x1, df$x2), loss = "L2", mode = "3d", thetastart = c(4,4),
#          step.size = 0.00001)

# plotEmpRisk(g, -5, 5, -5, 5, 30, df$y, data.frame(df$x1, df$x2), loss = "quant", mode = "3d", thetastart = c(4,4),
#          step.size = 0.001)
