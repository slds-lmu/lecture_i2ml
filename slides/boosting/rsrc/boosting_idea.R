library(gridExtra)

boosting = function (x, y, nboost, learning_rate, basis_fun = 
                       function (x) cbind(1, x)){
  X = basis_fun(x)
  
  overall_pred = rep(mean(y), length(y))
  pseudo_resids = y
  coefs = matrix(0, nrow = nboost, ncol = ncol(X))
  ylim = c(min(y) - mean(y), max(y))
  
  for (i in seq_len(nboost)) {
    # Update step:
    pseudo_resids = y - overall_pred
    coefs[i,] = learning_rate * solve(t(X) %*% X) %*% t(X) %*% pseudo_resids
    
    blearner_pred = X %*% coefs[i,]
    overall_pred = overall_pred + blearner_pred
  }
  
  return(coefs)
}

bTrafo = function (x) {
  margin = 0.1 * (max(x) - min(x))
  cbind(rep(1, length(x)),splines::splineDesign(knots = seq(min(x) - margin, max(x) + margin,
                                    length.out = 10), x = x, outer.ok = TRUE))
}

pred_boosting = function(coefs, x, basis_fun, it, offset=0){
  X = bTrafo(x)
  
  if(it == 0) pred = offset
  else pred = X %*% coefs[1,] + offset
  if(it > 1){
    for(i in seq(2,it)){
      pred = pred + X %*% coefs[i,]
    }
  }
  
  return(pred)
}

plot_splines_boosting_step = function(coefs, its = c(1,2), y_lim = c(-1.3,1.3),
                                      basis_fun = bTrafo){
  #browser()
  x_pl = seq(min(x), max(x), length.out = 100)
  y_pred0 = pred_boosting(coefs, x, basis_fun, its[1], mean(y))
  
  y_pred1 = pred_boosting(coefs, x, basis_fun, its[2], mean(y))
  y_pl_pred0 = pred_boosting(coefs, x_pl, basis_fun, its[1], mean(y)) 
  y_pl_pred1 = pred_boosting(coefs, x_pl, basis_fun, its[2], mean(y)) 
  
  pl_pred_data = data.frame(x=x,  
                            y_pred0=y_pred0,
                            y_pred1=y_pred1
  )
  
  pl_sm_pred_data = data.frame(x=x_pl,  
                            y_pred0=y_pl_pred0,
                            y_pred1=y_pl_pred1
  )
  
  pl_res_data = data.frame(x=x,  
                           res0 = y-y_pred0,
                           res1 = y-y_pred1
  )
  
  pl_pred_data = reshape2::melt(pl_pred_data, id.vars="x")
  pl_sm_pred_data = reshape2::melt(pl_sm_pred_data, id.vars="x")
  pl_arrow = data.frame(x = x, x_end=x, y = y_pred0, y_end=y)
  
  y_lim = c(-1.3,1.3)
  
  p_fit = ggplot(pl_data, aes(x=x, y=y)) + 
    geom_point() + 
    geom_point(data = pl_pred_data, aes(x=x, y=value, colour=variable)) + 
    geom_line(data = pl_sm_pred_data, aes(x=x, y=value, colour=variable)) +
    scale_colour_discrete(name = "Iteration", labels = 
                            c(as.expression(bquote(f^{'['*.(its[1])*']'})),
                              as.expression(bquote(f^{'['*.(its[2])*']'})))) +
    geom_segment(data=pl_arrow, aes(x=x, y=y, xend=x, yend=y_end),
                 alpha=0.2, arrow=arrow()) +
    ylim(y_lim) +
    ylab(expression("Target"~y)) +
    xlab(expression("Feature"~x)) +
#    annotate("label", label="frac(partialdiff~L,partialdiff~f(x^'(i)'))", 
#             parse=TRUE, x=11, y=-0.7) + 
    theme(legend.position = "bottom")
  
  p_res = ggplot(pl_res_data, aes(x=x, y=res0)) +
    geom_point() +
    geom_line(data = data.frame(x=x_pl,  
                                y_pred=y_pl_pred1-y_pl_pred0),
              aes(x=x, y=y_pred)) +
    ylim(y_lim) +
    ylab("Residuals of current model") +
    xlab(expression("Feature"~x))
  
  return(grid.arrange(p_fit, p_res, ncol=2))
}

# coefs = boosting(x, y, nboost = 100, learning_rate = 0.4, basis_fun = bTrafo)
# plot_splines_boosting_step(coefs, its=c(3,4))
