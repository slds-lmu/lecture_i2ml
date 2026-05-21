##################################################################
####################Risk for different functions##################
##################################################################
# Aim: motivation of risk minimization
# Plot with two or three functions plot including corresponding risk
# Using the absolute loss in order to create an easy understanding 
# of the concept risk and risk minimization 
# 

#######
#libraries

library(ggplot2)
library(gridExtra)
library(grid)

#######
# Create sample data
set.seed(1234)

#number of data points
n <- 15

# errors
sd <- 2
eps <- rnorm(n = n , mean = 0, sd = sd)

# x values
x <- seq (1,10,length.out = n)

#linear model 
b0 <- 1.25
b1 <- 0.9
y <- b0 + b1*x + eps


#####
#perfect model 
model_1 <- 1 + 1.5*x


model_2 <- 6 + -1*x
 
data <- data.frame(x = x, y = y, model_1 = model_1, model_2) 


residual_plot <- function(data, model, with_theta = FALSE){
  
  risk <- sum (abs(y-model))
  
  plot <- ggplot(data = data, mapping = aes(x = x, y=y)) +
    geom_point(size = 4) +
    geom_line (aes(x =x, y= model))+
    geom_segment(aes(xend = x, yend = model), 
                 alpha = .2,
                 colour = "blue", 
                 size = 1) +
    theme_classic() +
    ylim(c(-10,20))+
    theme(axis.text=element_text(size=25),
          axis.title=element_text(size=25),
          panel.border = element_rect(colour = "black", fill=NA, size=0.5))
  
  if(with_theta){
   plot <- plot+ 
     annotate(geom = "text", 
              x = 6.5, 
              y = -5, 
              label = bquote(bolditalic(R)[emp](theta)==~"="~.(round(risk,2))), 
              size = 7)  
   return(plot) #early exit
  }
    
  plot <- plot + annotate(geom = "text", 
                          x = 6.5, 
                          y = -5, 
                          label = bquote(bolditalic(R)[emp](f)==~"="~.(round(risk,2))), 
                          size = 7)
  return(plot)  
}

grid <- grid.arrange(
  residual_plot(data, model= model_1)+ 
    theme(plot.background = element_rect(fill = "white")),
  #residual_plot(data, model= model_2),
  residual_plot(data, model= model_2), ncol = 2)

ggsave(filename = "figure/ml-basic_riskmin-2-risk.png", plot = grid, width = 14, height = 3.5, units = "in")

#-----------------------------------------------------------
# SECOND PLOT WITH GREEN PLUS THETA INSTEAD OF F
# ----------------------------------------------------------
grid_green <- grid.arrange(
  residual_plot(data, model= model_1, with_theta = TRUE)+ 
    theme(plot.background = element_rect(fill = "lightgreen")),
  residual_plot(data, model= model_2, with_theta = TRUE), 
  ncol = 2)

ggsave(filename = "figure/ml-basic_riskmin-3-risk-min.png",plot = grid_green, width = 14, height = 3.5, units = "in")




