library(mlr3verse)
library(ggplot2)
library(viridis)

iris_task <- tsk("iris")$select(c("Sepal.Length", "Sepal.Width"))
iris_data <- iris_task$data()

p <- ggplot(data = iris_data, mapping = aes(x=Sepal.Length,y=Sepal.Width, fill=Species)) +
  geom_point(shape=21) +
  scale_fill_viridis(end=0.9, discrete = TRUE)

ggsave(filename = "../figure/iris_ds_plot.png", width = 5, height = 4)