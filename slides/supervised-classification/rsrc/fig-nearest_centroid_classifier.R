set.seed(7)

# goal here is to visualize a nearest centroid classifier and its contour (Euclidian distance)
# by first generating two clusters, and plotting a the line of a new datapoint to each centroid.

library(ggplot2)
library(dplyr)


# OPTIONS
plot_width <- 25
plot_height <- 7
plot_dpi <- 300
line_size <- 5
base_size <- 40
point_size <- 10
new_point_size <- 20

# DATA (and some manually added points to improve the figure)
cluster_1 <- data.frame(x = rnorm(15, mean = 1, sd = 2), 
                        y = rnorm(15, mean = 3, sd = 1.5), 
                        class = 'Class 1')

cluster_2 <- data.frame(x = rnorm(13, mean = 14, sd = 2), 
                        y = rnorm(13, mean = 3, sd = 1.5), 
                        class = 'Class 2')

extra_points_cluster_1 <- data.frame(
  x = c(10, 7, 6, 6.5),
  y = c(6, 5.5, 4.5, 5.3),
  class = 'Class 1'
)

extra_points_cluster_2 <- data.frame(
  x = c(10, 9, 8, 15, 14, 12.2, 11.2),
  y = c(1, 0.5, 0.3, 0.1, 0.1, 0.4, 0.3),
  class = 'Class 2'
)

# combines base clusters with additional points
cluster_1 <- rbind(cluster_1, extra_points_cluster_1)
cluster_2 <- rbind(cluster_2, extra_points_cluster_2)

data <- rbind(cluster_1, cluster_2)

centroid_1 <- colMeans(subset(data, class == 'Class 1')[, c('x', 'y')])
centroid_2 <- colMeans(subset(data, class == 'Class 2')[, c('x', 'y')])

new_point <- data.frame(x = 5.5, y = 1)

centroids <- data.frame(x = c(centroid_1['x'], centroid_2['x']), 
                        y = c(centroid_1['y'], centroid_2['y']), 
                        class = c('Class 1 Centroid', 'Class 2 Centroid'))

x_range <- seq(min(data$x) - 1, max(data$x) + 1, length.out = 100)
y_range <- seq(min(data$y) - 1, max(data$y) + 1, length.out = 100)
grid <- expand.grid(x = x_range, y = y_range)

grid <- grid %>%
  mutate(distance_to_centroid_1 = sqrt((x - centroid_1['x'])^2 + (y - centroid_1['y'])^2),
         distance_to_centroid_2 = sqrt((x - centroid_2['x'])^2 + (y - centroid_2['y'])^2),
         predicted_class = ifelse(distance_to_centroid_1 < distance_to_centroid_2, "Class 1", "Class 2"))

# plotting: This looks (and is) a little complicated, but the basic idea is to simply draw a line from our x to each centroid.
# the grid we calculated above is also tainted to form decision regions!
p <- ggplot() +
  geom_tile(data = grid, aes(x = x, y = y, fill = predicted_class), alpha = 0.2) +
  geom_point(data = data, aes(x = x, y = y, color = class), size = point_size) +
  geom_point(data = centroids, aes(x = x, y = y, color = class), shape = 17, size = (point_size+4), show.legend = FALSE) +
  geom_point(data = new_point, aes(x = x, y = y), shape = 16, size = new_point_size, color = 'black') +
  annotate("text", x = new_point$x, y = new_point$y + 1, label = "x", fontface = "bold", size = base_size / 4, color = "black") +
  geom_segment(aes(x = new_point$x, y = new_point$y, xend = centroid_1['x'], yend = centroid_1['y']), 
               size = line_size, linetype = 'dashed', color = '#E68A00') +
  geom_segment(aes(x = new_point$x, y = new_point$y, xend = centroid_2['x'], yend = centroid_2['y']), 
               size = line_size, linetype = 'dashed', color = '#0072B2') +
  geom_text(data = NULL, aes(x = (new_point$x + centroid_1['x']) / 2, y = (new_point$y + centroid_1['y']) / 2 + 0.8, label = 'd[1]'), parse = TRUE, size = base_size / 4, color = '#E68A00') +
  geom_text(data = NULL, aes(x = (new_point$x + centroid_2['x']) / 2, y = (new_point$y + centroid_2['y']) / 2 + 0.6, label = 'd[2]'), parse = TRUE, size = base_size / 4, color = '#0072B2') +
  scale_color_manual(values = c('Class 1' = '#E69F00', 'Class 2' = '#56B4E9', 'Class 1 Centroid' = '#E68A00', 'Class 2 Centroid' = '#0072B2')) +
  scale_fill_manual(values = c('Class 1' = '#E69F00', 'Class 2' = '#56B4E9')) +
  theme_minimal(base_size = base_size) +
  theme(legend.position = "none") +
  labs(x = expression(x[1]), y = expression(x[2]))

print(p)
ggsave("../figure/nearest_centroid_classifier.png", plot = p, width = plot_width, height = plot_height, dpi = plot_dpi)
