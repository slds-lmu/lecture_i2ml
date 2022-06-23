library(DiceKriging)
library(ggplot2)
library(patchwork)
library(scales)

scale = 4.5 * pi
f = function(x) x*sin(scale*x)
x_plot = seq(0, 1, 0.001)
plot(x_plot, f(x_plot))

set.seed(3)
x_init = c(runif(4) *  0.5, runif(3) * 0.1 + 0.9)

BO = function(x, x_test){
  theta <- 0.1; sigma <- 0.2; trend = c(0,0)
  model <- km(~x, design=data.frame(x=x), response=data.frame(y=f(x)), 
            covtype="matern5_2", coef.cov=theta, 
            coef.var=sigma^2, coef.trend = trend)
  p <- predict(model, data.frame(x=x_test), "SK")
  
  x_best_id = which.min(f(x))
  x_best = x[x_best_id]
  y_best = f(x)[x_best_id]

  kappa = 0.05
  Z = (-p$mean + y_best - kappa) / (p$sd)
  EI = (-p$mean + y_best - kappa) * pnorm(Z) + p$sd*dnorm(Z)
  
  x_prop_id = which.max(EI)
  list(pred = p, x_prop = x_test[x_prop_id], ei = EI)
}

archive = data.frame(x = x_init, type=factor("init", levels = c("init", "prop", "seq")))
plots = list()
  
for (i in 1:5){
  archive$type[archive$type == "prop"] = "seq"
  res = BO(archive$x, x_plot)
  p = res$pred
  EI = res$ei
  archive = rbind(archive, data.frame(x=res$x_prop, type="prop"))
  
  pred_plot_data = data.frame(x=x_plot, mu=p$mean, std = p$sd, type="yhat")
  truth_plot_data = data.frame(x=x_plot, mu=f(x_plot), std = 0, type="y")
  
  truth_pred_plot_data = rbind(pred_plot_data, truth_plot_data)
  
  pred_plot = ggplot(pred_plot_data, aes(x=x, y=mu)) + 
    geom_ribbon(aes(ymin= mu-std, ymax=mu+std), alpha=0.5) +
    geom_line(data=truth_pred_plot_data, aes(x=x, y=mu, linetype=type)) +
    geom_point(data=data.frame(x=archive$x, y=f(archive$x), type=archive$type), 
               aes(x=x, y=y, colour=type, shape=type), size=3) +
    ylab(expression(c(lambda))) + xlab(expression(lambda)) +
    scale_linetype("type", labels=list(expression(hat(c)(lambda)), expression(c(lambda)))) +
    guides(colour = guide_legend(order = 1), shape = guide_legend(order = 1)) +
    scale_colour_manual(values = hue_pal()(3))
  
  ei_plot = ggplot(data.frame(x = x_plot, ei = EI), aes(x=x, y=ei)) + geom_line() +
    ylab(expression(EI(lambda)))+ xlab(expression(lambda)) 
  
  plots[[i]] =  pred_plot / ei_plot
  
  pdf(paste0("../figure/seq_1d_bo", as.character(i), ".pdf"), width = 8, height = 4.5)
  print(pred_plot / ei_plot)
  dev.off()
}
