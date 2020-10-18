library(mlbench)
library(ggplot2)
library(viridis)
# 2 classes
p <- mlbench.2dnormals(n = 100, cl = 2, r = 1, sd = 0.5)

data <- data.frame(x1 = p$x[,1], x2 = p$x[,2], class = p$classes)

classif_plot <- ggplot(data = data, mapping = aes(x = x1, y = x2, color = class)) +
  geom_point(aes(shape= class), size = 3)+
  xlab(expression(x[1]))+
  ylab(expression (x[2])) 

classif_plot 

ggsave(filename = "figure_man/ml-basics-supervised-classif-task.png",plot = classif_plot, width = 4.5, height = 3, units = "in")




