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
b0 <- 1
b1 <- 0.5
y <- b0 + b1*x + eps


#####
#perfect model 
model_1 <- b0 + b1*x

model_2 <- b0 + (b1-0.4)*x

model_3 <- b0-10+ (b1+1.3)*x
 
data <- data.frame(x = x, y = y, model_1 = model_1, model_2 = model_2, model_3) 


residual_plot <- function(data, model){
  
  risk <- sum (abs(y-model))/nrow(data)
  
  ggplot(data = data, mapping = aes(x = x, y=y)) +
    geom_point() +
    geom_line (aes(x =x, y= model))+
    geom_segment(aes(xend = x, yend = model), alpha = .2) +
    theme_bw() +
    ylim(c(-10,10))+
    annotate("text", x = 6.5, y = -5, label = bquote(bolditalic(R)[emp](f)==~"="~.(risk)))
    #annotate("text", x = 6.5, y = -5, label = bquote(bolditalic(R)[emp](f)== frac(1,n) %*% sum(L(y^(i), f(bold(x)^(i))), i==1, n)~"="~.(risk)))
  
}

grid <- grid.arrange(
  residual_plot(data, model= model_1),
  #residual_plot(data, model= model_2),
  residual_plot(data, model= model_3), ncol = 2)

ggsave("figure_man/ml-basic_riskmin-compare-risk.png", grid)


