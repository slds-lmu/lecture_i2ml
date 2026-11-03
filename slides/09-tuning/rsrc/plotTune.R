library(ggplot2)

plotTune = function(d) {
  
  d$TestAccuracy = mvtnorm::dmvnorm(x = d, 
                                    mean = c(5,5), 
                                    sigma = 40 * diag(2)
                                    ) * 120 + 0.4
  
  pl = ggplot(data = d, aes(x = x, y = y, color = TestAccuracy))
  pl = pl + scale_color_viridis_c(end = .9)
  pl = pl + geom_point(size = d$TestAccuracy * 4)
  pl = pl + 
    xlab("Hyperparameter 1") + 
    ylab("Hyperparameter 2") + 
    coord_fixed()

  return(pl)
  
}
