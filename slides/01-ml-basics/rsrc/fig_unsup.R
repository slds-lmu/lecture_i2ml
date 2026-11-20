library(mlr)
library(ggplot2)

set.seed(1)
df4 = getTaskData(iris.task)
m = as.matrix(cbind(df4$Petal.Length, df4$Petal.Width), ncol = 2)
cl = (kmeans(m,3))
df4$cluster = factor(cl$cluster)
centers = as.data.frame(cl$centers)
pl = ggplot(data = df4, aes(x = Petal.Length, y = Petal.Width, color = cluster)) +
 geom_point(size = 4) +
 geom_point(data = centers, aes(x = V1, y = V2, color = 'Center'), pch = 4, size = 4, col = "black") +
   #stat_ellipse(type = "t", level = c(0.725, 0.925)) +
  geom_point(data = centers, aes(x = V1, y = V2, color = 'Center'), size = c(60, 60, 45),   alpha = .2, pch = 21, fill = "blue", col = "black") +
 theme(legend.position = "none")

ggsave(filename = "../figure/unsup.pdf", 
       plot = pl, 
       width = 8, height = 8, units = "cm")

