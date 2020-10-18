#### create example graph regression
#######
#libraries
library(ggplot2)

#######
# Create sample data
set.seed(1234)

#number of data points
n <- 75

# errors
sd <- 2
eps <- rnorm(n = n , mean = 0, sd = sd)

# x values
x <- seq (1,10,length.out = n)

#linear model 
b0 <- 1
b1 <- 2
y <- b0 + b1*x + eps


#####
#perfect model 
model <- b0 + b1*x

data <- data.frame(x = x, y = y, model = model) 


regression_plot <- ggplot(data = data, mapping = aes(x = x, y=y)) +
    geom_point() +
    geom_line (aes(x =x, y= model), color = "blue")
    

regression_plot

ggsave(filename = "figure_man/ml-basics-supervised-regression-task.png",plot = regression_plot, width = 4.5, height = 3, units = "in")


