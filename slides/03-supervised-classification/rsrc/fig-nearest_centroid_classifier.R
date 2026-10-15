# goal here is to visualize a nearest centroid classifier and its contour (Euclidian distance)
# by first generating two clusters, and plotting a the line of a new datapoint to each centroid.

set.seed(3)

library(ggplot2)
library(dplyr)

# OPTIONS
plot_width <- 20
plot_height <- 11
plot_dpi <- 300
line_size <- 5
base_size <- 40
point_size <- 10
new_point_size <- 20

# DATA
cluster_1 <- data.frame(x = rnorm(20, mean = 6, sd = 3.5), 
                        y = rnorm(20, mean = 10, sd = 3), 
                        class = 'Class 1')

cluster_2 <- data.frame(x = rnorm(20, mean = 24, sd = 3.5), 
                        y = rnorm(20, mean = 8, sd = 4), 
                        class = 'Class 2')

# data is both of our clusters together
data <- rbind(cluster_1, cluster_2)

centroid_1 <- colMeans(subset(data, class == 'Class 1')[, c('x', 'y')])
centroid_2 <- colMeans(subset(data, class == 'Class 2')[, c('x', 'y')])

new_point <- data.frame(x = 12, y = 1)

centroids <- data.frame(x = c(centroid_1['x'], centroid_2['x']), 
                        y = c(centroid_1['y'], centroid_2['y']), 
                        class = c('Class 1 Centroid', 'Class 2 Centroid'))

x_range <- seq(0, 30, length.out = 100)
y_range <- seq(0, 15, length.out = 100)
grid <- expand.grid(x = x_range, y = y_range)

grid <- grid %>%
  mutate(distance_to_centroid_1 = sqrt((x - centroid_1['x'])^2 + (y - centroid_1['y'])^2),
         distance_to_centroid_2 = sqrt((x - centroid_2['x'])^2 + (y - centroid_2['y'])^2),
         predicted_class = ifelse(distance_to_centroid_1 < distance_to_centroid_2, "Class 1", "Class 2"))

# calculates midpoint and orthogonal line for the decision boundary
midpoint <- data.frame(
  x = (centroid_1['x'] + centroid_2['x']) / 2,
  y = (centroid_1['y'] + centroid_2['y']) / 2
)
slope <- (centroid_2['y'] - centroid_1['y']) / (centroid_2['x'] - centroid_1['x'])
orthogonal_slope <- -1 / slope

# generate points for the orthogonal line
x1 <- midpoint$x - (midpoint$y / orthogonal_slope)
y1 <- 0
x2 <- midpoint$x + ((15 - midpoint$y) / orthogonal_slope)
y2 <- 15

# plotting: we want a) the data, b) the new datapoint x, c) the centroids, d) lines between centroid and x,
# e) a line between each centroid, f) an explicit decision boundary that is orthogonal to the the line between centroids
# and everything annotated!
p <- ggplot() +
  geom_tile(data = grid, aes(x = x, y = y, fill = predicted_class), alpha = 0.2) +
  geom_point(data = data, aes(x = x, y = y, color = class), size = point_size) +
  geom_point(data = centroids, aes(x = x, y = y, color = class), shape = 17, size = (point_size+4), show.legend = FALSE) +
  geom_point(data = new_point, aes(x = x, y = y), shape = 16, size = new_point_size, color = 'black') +
  annotate("text", x = new_point$x, y = new_point$y + 1.5, label = "x", fontface = "bold", size = base_size / 2, color = "black") +
  geom_segment(aes(x = new_point$x, y = new_point$y, xend = centroid_1['x'], yend = centroid_1['y']), 
               size = line_size, linetype = 'dashed', color = '#E68A00') +
  geom_segment(aes(x = new_point$x, y = new_point$y, xend = centroid_2['x'], yend = centroid_2['y']), 
               size = line_size, linetype = 'dashed', color = '#0072B2') +
  geom_segment(aes(x = centroid_1['x'], y = centroid_1['y'], xend = centroid_2['x'], yend = centroid_2['y']), 
               size = line_size / 1.5, linetype = 'dotted', color = 'darkgray') +
  geom_segment(aes(x = x1, y = y1, xend = x2, yend = y2),
               size = line_size, linetype = 'dotdash', color = 'black') +
  geom_text(data = NULL, aes(x = (new_point$x + centroid_1['x']) / 2, y = (new_point$y + centroid_1['y']) / 2 - 1.3, label = 'd[1]'), parse = TRUE, size = base_size/2, color = '#E68A00') +
  geom_text(data = NULL, aes(x = (new_point$x + centroid_2['x']) / 2, y = (new_point$y + centroid_2['y']) / 2 - 1.1, label = 'd[2]'), parse = TRUE, size = base_size/2, color = '#0072B2') +
  geom_text(aes(x = midpoint$x - 3.3, y = midpoint$y - 0.7, label = 'd[1] < d[2]'), parse = TRUE, size = base_size / 2, color = 'darkgray') +
  geom_text(aes(x = midpoint$x + 3.3, y = midpoint$y + 0.7, label = 'd[2] < d[1]'), parse = TRUE, size = base_size / 2, color = 'darkgray') +
  scale_color_manual(values = c('Class 1' = '#E69F00', 'Class 2' = '#56B4E9', 'Class 1 Centroid' = '#E68A00', 'Class 2 Centroid' = '#0072B2')) +
  scale_fill_manual(values = c('Class 1' = '#E69F00', 'Class 2' = '#56B4E9')) +
  theme_minimal(base_size = base_size) +
  theme(legend.position = "none", aspect.ratio = 0.5) +
  labs(x = expression(x[1]), y = expression(x[2]))

print(p)
ggsave("../figure/nearest_centroid_classifier.png", plot = p, width = plot_width, height = plot_height, dpi = plot_dpi)
