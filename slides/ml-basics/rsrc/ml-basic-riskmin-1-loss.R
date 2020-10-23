##################################################################
####################Loss in a function ###########################
##################################################################
# Aim: show loss of a single observation

#------------------------------------------------------------------
# Libraries 
#------------------------------------------------------------------

library(ggplot2)
library(gridExtra)
library(grid)

#------------------------------------------------------------------
# Function: Plot model + show one loss
#------------------------------------------------------------------

#plot points + model 
plot_data <- function(data){
  ggplot(data = data, mapping = aes(x = x, y=y)) +
    geom_point(size= 4) +
    geom_line (aes(x =x, y= model_1))+
    theme_classic() +
    ylim(c(-10,10)) +
    theme(axis.text=element_text(size=25),
          axis.title=element_text(size=25),
          panel.border = element_rect(colour = "black", fill=NA, size=0.5))
}

# plot + loss 
plot_loss <- function (data, example, type = c("abs", "sqrd")){
  loss_example_sqrd  <- (model_1[example]-y[example])^2
  loss_example_abs <- abs(model_1[example]-y[example])
  if(type=="abs"){
    
    plot <- plot_data(data) + 
      geom_segment(aes(x = x[example], 
                       y = model_1[example], 
                       xend = x[example], 
                       yend = y[example]),
                   colour = "blue", 
                   size = 1) +
      annotate("text", x = 5.5, y = -5, label = bquote(bolditalic(L)(y,f(bold(.(round(x[example],2)))))~"="~"|"~.(round(model_1[example],2))~"-"~(.(round(y[example],2)))~"|"~"="~.(round(loss_example_abs,2))), size = 7)
  }
  if(type=="sqrd"){
    
    plot <- plot_data(data) + 
      geom_rect(aes(xmin=x[example], 
                   xmax=x[example]+loss_example_abs, 
                   ymin=model_1[example], 
                   ymax=y[example]), 
               fill="blue", 
               alpha=0.01, 
               inherit.aes = FALSE,
               color = "blue") +
      annotate("text", x = 5.5, y = -5, label = bquote(bolditalic(L)(y,f(bold(.(round(x[example],2)))))~"="~"("~.(round(model_1[example],2))~"-"~(.(round(y[example],2)))~")"^2~"="~.(round(loss_example_sqrd,2))), size = 7)
  } 
  
  plot
  
}

#------------------------------------------------------------------
# Function: Loss function plot
#------------------------------------------------------------------

#different loss functions

loss_type <- function(x, type = c("abs", "sqrd")){
  if(type=="abs") return_loss <- abs(x)
  if(type=="sqrd")return_loss <- (x)^2
  return_loss
}


plot_loss_function <- function (data, example, type = c("abs", "sqrd")){
  
  #create data for loss function
  x_seq <- seq(-5,5,0.01)
  loss_function <- loss_type(x_seq, type)
  data_loss_function <- data.frame(x = x_seq, y = loss_function)
  
  #show loss data of example
  loss <- loss_type(data$model_1-data$y, type)
  residuals <- model_1 - y
  data_examples <- data.frame(residuals = residuals, loss = loss)
  
  #create plot
  
  loss_function_plot <- ggplot(data = data_loss_function, mapping = aes(x = x, y = y))+
    geom_line() +
    geom_point(mapping = aes(x=residuals, y=loss), data = data_examples, shape =1, size = 4, color = "black")+
    xlim(-5,5) +
    theme_classic()+
    geom_segment(mapping = aes(x = residuals, 
                               y = loss, 
                               xend = residuals, 
                               yend = rep(0, length(residuals))),
                 colour = "black", 
                 data = data_examples, 
                 size= 1)  +
    geom_segment(mapping = aes(x = residuals[example], 
                               y = loss[example], 
                               xend = residuals[example], 
                               yend = 0),
                 colour = "blue", 
                 data = data_examples, 
                 size = 1)  +
    xlab ( "y - f(x)")+
    ylab ("L(y, f(x))") +
    theme(axis.text=element_text(size=25),
          axis.title=element_text(size=25),
          panel.border = element_rect(colour = "black", fill=NA, size=0.5)) 
  
  
  loss_function_plot
  
}

#------------------------------------------------------------------
# Function: Plot both plot
#------------------------------------------------------------------

plot_two <- function (data, example, type = c("abs", "sqrd")){
  loss_plot <-plot_loss (data, example, type = type)
  loss_plot
  
  loss_function_plot <- plot_loss_function (data, example, type = type)
  loss_function_plot
  
  gridExtra::grid.arrange(loss_plot, loss_function_plot , ncol = 2)
}
#------------------------------------------------------------------
# Create data 
#------------------------------------------------------------------

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


#####################################
# input for the functions: 
#####################################
data <- data.frame(x = x, y = y, model_1 = model_1) 

#at which observation do we have a closer look (here: number 4)
example <- 4


#------------------------------------------------------------------
# Plot both plot + save them 
#------------------------------------------------------------------
# plot absolute loss
abs_plot <- plot_two (data, example, type = "abs")
ggsave(filename = "figure/ml-basic_riskmin-1-loss_abs.png", plot = abs_plot , width = 14, height = 5, units = "in")


# plot absolute loss
sqrd_plot <- plot_two (data, example, "sqrd")
ggsave(filename = "figure/ml-basic_riskmin-1-loss_sqrd.png", plot = sqrd_plot , width = 14, height = 5, units = "in")


