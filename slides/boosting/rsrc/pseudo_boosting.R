library(gridExtra)

pseudo_boosting = function(y, nboost=2, learning_rate = 0.6){
  overall_pred = rep(mean(y), length(y))
  coefs = matrix(0, nrow = nboost, ncol = length(y))
  coefs[1, ] = overall_pred 
  
  ylim = c(min(y) - mean(y), max(y))

  for (i in seq(2,nboost)) {
    # Update step:
    pseudo_resids = y - overall_pred # (in this case actually true resids)
    coefs[i,] = learning_rate * pseudo_resids
    
    blearner_pred = coefs[i,]
    overall_pred = overall_pred + blearner_pred  
  }
  
  return(coefs)  
}

pseudo_pred = function(coefs, i){
  r = coefs[1:i,]
  if(is.matrix(r))            
    return(colSums(r))
  else
    return(r)
}


#extract legend
#https://github.com/hadley/ggplot2/wiki/Share-a-legend-between-two-ggplot2-graphs
g_legend<-function(a.gplot){
  tmp <- ggplot_gtable(ggplot_build(a.gplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)}


plot_pseudo_boosting_step = function(coefs, its = c(1,2), y_lim = c(-1.3,1.3)){
  y_pred0 = pseudo_pred(coefs, its[1])
  y_pred1 = pseudo_pred(coefs, its[2])
  
  pl_pred_o_data = data.frame(x=x,  
                            y_pred0=y_pred0,
                            y_pred1=y_pred1
  )
  
  pl_res_data = data.frame(x=x,  
                           res0 = y-y_pred0,
                           res1 = y-y_pred1
  )
  
  pl_pred_data = reshape2::melt(pl_pred_o_data, id.vars="x")
  pl_arrow = data.frame(x = x, x_end=x, y = y_pred0, y_end=y)
  
  
  p_fit = 
    ggplot(pl_data, aes(x=x, y=y)) + 
    geom_point() + 
    geom_point(data = pl_pred_data, aes(x=x, y=value, colour=variable)) + 
    geom_line(data = pl_pred_data, aes(x=x, y=value, colour=variable), lty = "dotted") +
    scale_colour_discrete(name = "Iteration", labels = 
                            c(as.expression(bquote(f^{'['*.(its[1]-1)*']'})),
                            as.expression(bquote(f^{'['*.(its[2]-1)*']'})))) +
    geom_segment(data=pl_arrow, aes(x=x, y=y, xend=x, yend=y_end),
                 alpha=0.2, arrow=arrow()) +
    ylim(y_lim) +
    ylab(expression("Target"~y)) +
    xlab(expression("Feature"~x)) +
#    annotate("label", label="frac(partialdiff~L,partialdiff~f(x^'(i)'))", 
#             parse=TRUE, x=11, y=-0.7)  +
    theme(legend.position = "bottom")
  
  p_res = ggplot(pl_res_data, aes(x=x, y=res0)) +
    geom_point() +
    geom_line(data = pl_pred_o_data,  
              aes(x=x, y=y_pred1-y_pred0), lty = "dotted") +
    ylim(y_lim) +
    ylab("Residuals of current model") +
    xlab(expression("Feature"~x))
  
  mylegend<-g_legend(p_fit)
  
  p3 <- grid.arrange(arrangeGrob(p_fit + theme(legend.position="none"),
                                 p_res + theme(legend.position="none"),
                                 nrow=1),
                     mylegend, nrow=2,heights=c(10, 1))
  
  return(p3)
}





