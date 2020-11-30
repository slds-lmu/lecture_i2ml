# PREREQ -----------------------------------------------------------------------

library(knitr)
library(tidyverse)
library(ggplot2)
library(mlr3)
library(mlr3learners)
library(mlr3viz)
library(gridExtra)

# FUNCTIONS --------------------------------------------------------------------

make_circle = function(center, radius, npoints = 100) {
  
  t = seq(0, 2 * pi, length.out = npoints)
  x = center[1L] + radius * cos(t)
  y = center[2L] + radius * sin(t)
  
  data.frame(Sepal.Length = x, Sepal.Width = y, Species = NA)
  
}

plot_pred = function(k) {
  
  learner = lrn("classif.kknn", k = k, predict_type = "prob")
  plot_learner_prediction(learner, task) +
    theme(legend.position = "none")

}

# DATA -------------------------------------------------------------------------

iris_knn <- iris %>% 
  select(Sepal.Length, Sepal.Width, Species)

index_i <- iris_knn %>%
  rowid_to_column() %>%
  filter(Sepal.Length == 6.4, Sepal.Width == 3.2, Species == "virginica") %>% 
  select(rowid) %>% 
  as.numeric()

x_i <- iris_knn[index_i, ]

dist_mat <- dist(iris_knn %>% select(-Species), method = "euclidean")
dist_vec_x_i <- sort(as.matrix(dist_mat)[index_i, ])

circle_data <- make_circle(c(x_i[[1]], x_i[[2]]), dist_vec_x_i[50])

task = tsk("iris")
task$select(c("Sepal.Width", "Sepal.Length"))

# PLOT -------------------------------------------------------------------------

pdf("../figure/knn-neighborhood.pdf", width = 25, height = 6)

p = ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
  geom_point(size = 3) + 
  geom_point(
    x_i, 
    mapping = aes(Sepal.Length, Sepal.Width), 
    color = 1, 
    size = 3) 
p = p + geom_polygon(
  circle_data, 
  mapping = aes(x = Sepal.Length, y = Sepal.Width),
  alpha = 0.2, 
  fill = "#619CFF")
p = p + 
  theme(text = element_text(size = 40)) +
  theme(legend.position = "none")

grid.arrange(
  p,
  plot_pred(1) + theme(text = element_text(size = 40)), 
  plot_pred(50) + theme(text = element_text(size = 40)),
  ncol = 3)

ggsave("../figure/knn-neighborhood.pdf", width = 25, height = 6)
dev.off()
