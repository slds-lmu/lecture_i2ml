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

#calculation
example_oberservation <- 4
loss_example  <- abs(model_1[example_oberservation]-y[example_oberservation])

  
loss_plot <-   ggplot(data = data, mapping = aes(x = x, y=y)) +
    geom_point(size= 4) +
    geom_line (aes(x =x, y= model_1))+
    geom_segment(aes(x = x[example_oberservation], 
                       y = model_1[example_oberservation], 
                       xend = x[example_oberservation], 
                       yend = y[example_oberservation]),
                 colour = "blue", size = 1)+
    #geom_segment(aes(xend = x, yend = model), alpha = .2) +
    theme_classic() +
    ylim(c(-10,10))+
    annotate("text", x = 5.5, y = -5, label = bquote(bolditalic(L)(y,f(bold(.(round(x[example_oberservation],2)))))~"="~"|"~.(round(model_1[example_oberservation],2))~"-"~(.(round(y[example_oberservation],2)))~"|"~"="~.(round(loss_example,2))), size = 7) +
    theme(axis.text=element_text(size=25),
         axis.title=element_text(size=25,
                                 face="bold"))
  
    
  
loss_plot

##### residual plot


x_seq <- seq(-5,5,0.01)
loss_function <- abs(x_seq)
data_loss_function <- data.frame(x = x_seq, y = loss_function)


loss  <- abs(model_1-y)
residuals <- model_1 - y
data_residuals <- data.frame(residuals = residuals, loss = loss)

residual_plot <- ggplot(data = data_loss_function, mapping = aes(x = x, y = y))+
  geom_line() +
  geom_point(mapping = aes(x=residuals, y=loss), data = data_residuals, shape =1, size = 4)+
  xlim(-5,5) +
  theme_classic()+
  geom_segment(mapping = aes(x = residuals, 
                             y = loss, 
                             xend = residuals, 
                             yend = rep(0, n)),
               colour = "black", data = data_residuals, size= 1)  +
  geom_segment(mapping = aes(x = residuals[example_oberservation], 
                     y = loss[example_oberservation], 
                     xend = residuals[example_oberservation], 
                     yend = 0),
                 colour = "blue", data = data_residuals, size = 1)  +
  xlab ( "y - f(x)")+
  ylab ("L(y, f(x))") +
  theme(axis.text=element_text(size=25),
        axis.title=element_text(size=25,face="bold"))

residual_plot     
    
ggsave(filename = "figure/ml-basic_riskmin-1-loss.png", plot = gridExtra::grid.arrange(loss_plot, residual_plot , ncol = 2), width = 14, height = 5, units = "in")


