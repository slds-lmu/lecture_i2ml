library("bmrm")
library("MASS")
library("data.table")

source("loss_functions.R")

#1 Derive a dataframe with all optimal constant models


computeOptimalConstant = function(df, loss, a = 2) {
  switch(loss, 
    L1 = rq(y ~ 1, data = df, .5)$fitted.values, 
    L2 = lm(y ~ 1, data = df)$fitted.values,
    quant25 = quantreg::rq(y ~ 1, data = df, .25)$fitted.values,
    quant75 = quantreg::rq(y ~ 1, data = df, .75)$fitted.values,
    Huber1 = rlm(y ~ 1, data = df, scale.est = "Huber", k2 = 2, maxit = 100)$fitted.values,
    eps2 = {
      lm_eps_2 = nrbm(epsilonInsensitiveRegressionLoss(x = matrix(rep(1, times = nrow(df))),y = df$y, epsilon = 2))
      predict(lm_eps_2, matrix(rep(1, times = nrow(df))))
    }, 
    log_barrier = {
      f = function(c) {
        mean(log_barrier(df$y - c, a = a))
      }

      c = optimize(f, interval = c(-2, 2))

      if (!is.finite(c$objective)) {
        c = NA 
      } else {
        c = c$minimum        
      } 
      return(c)
    })
}


plotConstantModel = function(df, loss_type = c("L1", "L2", "quant25", "quant75", "Huber1", "eps2", "log_barrier"),
                             labels = NULL, a = 2) {
  
  optimal_constants = lapply(loss_type, function(loss) computeOptimalConstant(df, loss, a = a))

  dfp = do.call(cbind, optimal_constants)
  colnames(dfp) = loss_type
  dfp = cbind(data.frame(x = df$x), dfp)

  dfm = melt(dfp, id.vars = c("x"))
  colnames(dfm) = c("x", "loss", "y")

  dfm = setDT(dfm)

  p = ggplot() + geom_point(data = df, aes(x = x, y = y))
  p = p + geom_line(data = dfm[loss %in% loss_type, ],
                    aes(x = x, y = y, colour = loss))
  if (!is.null(labels)) {
    p = p + scale_color_discrete(
      name = "", 
      labels = labels[1:length(loss_type)])
  }
  p = p + theme(legend.position = 'top', legend.direction = 'horizontal')
  
  return(p)
}






#2 Create labels for plots
# labelsPlot = c("L2", "L1", expression(paste("Quantile (", alpha, " = 0.25)")), 
#                 # expression(paste("Quantile (", alpha, " = 0.75)")),
#                 # expression(paste("Huber (", delta, " = 1.0)")),
#                 # expression(paste(epsilon, "-insens. (", epsilon, " = 2)")))
  
  
  
#3 Define plotConstantModel function



# #4 Create plots
# plotL2 = plotConstantModel(df, "L2", labelsPlot[1])
# plotL1 = plotConstantModel(df, c("L2", "L1"), labelsPlot[1:2])
# plotq25q75 = plotConstantModel(df, c("L2", "L1", "quant25", "quant75"), labelsPlot[1:4])
# plotHuber = plotConstantModel(df, c("L2", "L1", "quant25", "quant75", "Huber1"), labelsPlot[1:5])
# plotEps = plotConstantModel(df, c("L2", "L1", "quant25", "quant75", "Huber1", "eps2"), labelsPlot[1:6])
# 
# #5 Save plots
# plots = list(plotL2, plotL1, plotq25q75, plotHuber, plotEps)
# plotNames = list("3_0_plot_l2.png", "3_1_plot_l1.png", "3_2_plot_quant.png", "3_3_plot_huber.png", "3_4_plot_eps.png")
# mapply(function(x, y) ggsave(x, filename = y, path = "figure_man", width = 200, height = 140, units = "mm"),
#        x = plots, y = plotNames)
                              

