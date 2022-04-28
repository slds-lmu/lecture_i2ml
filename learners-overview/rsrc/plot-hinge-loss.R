library(ggplot2)

# LOSS FUNCTION ---------------------------------------------------------------


calc_hinge_loss = function(f) {sapply(f, FUN = function(x) max(0, 1 - x))}


# PLOT ------------------------------------------------------------------------
  x = seq(-2, 1.5, length.out = 10000)
  
  
  plot <- ggplot(data.frame(x), aes(x = x)) +
    labs(x = expression(paste(italic(y), italic(f))), 
               y = expression(paste(italic(L), "(", italic(y), ",", italic(f),")"))) +
    stat_function(fun = "calc_hinge_loss", size = 2.5) +
    geom_hline(yintercept = 0) +   # Axes
    geom_vline(xintercept = 0) +
    scale_y_continuous(limits = c(0, 2)) +
    scale_x_continuous(limits = c(-1, 3))+
    theme_minimal() + 
    theme(legend.position = "none") + #no legend
    scale_color_viridis_d(begin = 0.9)#color-blind friendly
  
plot

ggsave(filename="figure/plot-hinge-loss.png")

