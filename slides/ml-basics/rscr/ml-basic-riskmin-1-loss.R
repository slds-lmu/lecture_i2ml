##################################################################
####################Loss in a function ###########################
##################################################################
# Aim: show loss of a single observation

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



 
data <- data.frame(x = x, y = y, model_1 = model_1) 


example_oberservation <- 4
  
loss  <- abs(model_1[example_oberservation]-y[example_oberservation])
  
loss_plot <-   ggplot(data = data, mapping = aes(x = x, y=y)) +
    geom_point() +
    geom_line (aes(x =x, y= model_1))+
    geom_segment(aes(x = x[example_oberservation], 
                       y = model_1[example_oberservation], 
                       xend = x[example_oberservation], 
                       yend = y[example_oberservation]),
                 colour = "blue")+
    #geom_segment(aes(xend = x, yend = model), alpha = .2) +
    theme_bw() +
    ylim(c(-10,10))+
    annotate("text", x = 5.5, y = -5, label = bquote(bolditalic(L)(y,f(bold(.(x[example_oberservation]))))~"="~"|"~.(model_1[example_oberservation])~"-"~.(y[example_oberservation])~"|"~"="~.(loss)))
    
  
loss_plot



ggsave("figure_man/ml-basic_riskmin-1-loss.png", loss_plot)


