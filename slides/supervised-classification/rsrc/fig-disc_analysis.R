# goal here is to visualize LDA/QDA with µs and 1st/2nd eigenvector (principal components)
library(ggplot2)
library(MASS)
library(car)

# OPTIONS
plot_width <- 20
plot_height <- 10
plot_dpi <- 300
line_size <- 5
base_size <- 40
point_size <- 5

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

set.seed(123)

# LDA data generation (imbalanced two-class)
n_a_lda <- 100
n_b_lda <- 200

classa_lda <- data.frame(mvrnorm(n = n_a_lda, 
                                 mu = c(10, 2), 
                                 Sigma = matrix(c(2, 0, 0, 2), ncol = 2)))
classb_lda <- data.frame(mvrnorm(n = n_b_lda, 
                                 mu = c(20, 7), 
                                 Sigma = matrix(c(8, -6, -6, 8), ncol = 2)))

# combines LDA data into one
df_lda <- rbind(
  cbind(classa_lda, y = "a"),
  cbind(classb_lda, y = "b")
)
colnames(df_lda) <- c("x1", "x2", "y")

# QDA data generation (three-class!)
n_qda <- 150

classa_qda <- data.frame(mvrnorm(n = n_qda, 
                                 mu = c(10, 2), 
                                 Sigma = matrix(c(2, 0, 0, 2), ncol = 2)))
classb_qda <- data.frame(mvrnorm(n = n_qda, 
                                 mu = c(20, 7), 
                                 Sigma = matrix(c(8, -6, -6, 8), ncol = 2)))
classc_qda <- data.frame(mvrnorm(n = n_qda, 
                                 mu = c(15, 15), 
                                 Sigma = matrix(c(6, 3, 3, 6), ncol = 2)))

# combines QDA data into one
df_qda <- rbind(
  cbind(classa_qda, y = "a"),
  cbind(classb_qda, y = "b"),
  cbind(classc_qda, y = "c")
)
colnames(df_qda) <- c("x1", "x2", "y")

# mean and variance calculations for LDA
mu_a_lda <- colMeans(df_lda[df_lda$y == "a", 1:2])
mu_b_lda <- colMeans(df_lda[df_lda$y == "b", 1:2])

# pooled variance calculation for LDA (shared covariance!!)
var_lda <- ((n_a_lda - 1) * var(df_lda[df_lda$y == "a", 1:2]) + (n_b_lda - 1) * var(df_lda[df_lda$y == "b", 1:2])) / (n_a_lda + n_b_lda - 2)

# mean and variance Calculations for QDA
mu_a_qda <- colMeans(df_qda[df_qda$y == "a", 1:2])
mu_b_qda <- colMeans(df_qda[df_qda$y == "b", 1:2])
mu_c_qda <- colMeans(df_qda[df_qda$y == "c", 1:2])

var_qda_a <- var(df_qda[df_qda$y == "a", 1:2])
var_qda_b <- var(df_qda[df_qda$y == "b", 1:2])
var_qda_c <- var(df_qda[df_qda$y == "c", 1:2])

# PLOTTING
# create ellipsoids for LDA
a_ell_lda_1 <- as.data.frame(ellipse(center = mu_a_lda, shape = var_lda, radius = 1, draw = FALSE))
a_ell_lda_1_5 <- as.data.frame(ellipse(center = mu_a_lda, shape = var_lda, radius = 1.5, draw = FALSE))
a_ell_lda_2 <- as.data.frame(ellipse(center = mu_a_lda, shape = var_lda, radius = 2, draw = FALSE))
b_ell_lda_1 <- as.data.frame(ellipse(center = mu_b_lda, shape = var_lda, radius = 1, draw = FALSE))
b_ell_lda_1_5 <- as.data.frame(ellipse(center = mu_b_lda, shape = var_lda, radius = 1.5, draw = FALSE))
b_ell_lda_2 <- as.data.frame(ellipse(center = mu_b_lda, shape = var_lda, radius = 2, draw = FALSE))
colnames(a_ell_lda_1) <- colnames(a_ell_lda_1_5) <- colnames(a_ell_lda_2) <- colnames(b_ell_lda_1) <- colnames(b_ell_lda_1_5) <- colnames(b_ell_lda_2) <- c("x1", "x2")

# create ellipsoids for QDA
a_ell_qda_1 <- as.data.frame(ellipse(center = mu_a_qda, shape = var_qda_a, radius = 1, draw = FALSE))
a_ell_qda_1_5 <- as.data.frame(ellipse(center = mu_a_qda, shape = var_qda_a, radius = 1.5, draw = FALSE))
a_ell_qda_2 <- as.data.frame(ellipse(center = mu_a_qda, shape = var_qda_a, radius = 2, draw = FALSE))
b_ell_qda_1 <- as.data.frame(ellipse(center = mu_b_qda, shape = var_qda_b, radius = 1, draw = FALSE))
b_ell_qda_1_5 <- as.data.frame(ellipse(center = mu_b_qda, shape = var_qda_b, radius = 1.5, draw = FALSE))
b_ell_qda_2 <- as.data.frame(ellipse(center = mu_b_qda, shape = var_qda_b, radius = 2, draw = FALSE))
c_ell_qda_1 <- as.data.frame(ellipse(center = mu_c_qda, shape = var_qda_c, radius = 1, draw = FALSE))
c_ell_qda_1_5 <- as.data.frame(ellipse(center = mu_c_qda, shape = var_qda_c, radius = 1.5, draw = FALSE))
c_ell_qda_2 <- as.data.frame(ellipse(center = mu_c_qda, shape = var_qda_c, radius = 2, draw = FALSE))
colnames(a_ell_qda_1) <- colnames(a_ell_qda_1_5) <- colnames(a_ell_qda_2) <- colnames(b_ell_qda_1) <- colnames(b_ell_qda_1_5) <- colnames(b_ell_qda_2) <- colnames(c_ell_qda_1) <- colnames(c_ell_qda_1_5) <- colnames(c_ell_qda_2) <- c("x1", "x2")

plot_lda_1 <- ggplot(data = df_lda, aes(x = x1, y = x2, color = y)) +
  geom_point(size = point_size, show.legend = TRUE) +
  geom_path(data = a_ell_lda_1, aes(x = x1, y = x2), color = "#E69F00", alpha = 0.6, linewidth = line_size) +
  geom_path(data = a_ell_lda_1_5, aes(x = x1, y = x2), color = "#E69F00", alpha = 0.6, linewidth = line_size) +
  geom_path(data = a_ell_lda_2, aes(x = x1, y = x2), color = "#E69F00", alpha = 0.6, linewidth = line_size) +
  geom_path(data = b_ell_lda_1, aes(x = x1, y = x2), color = "#4DA6DA", alpha = 0.6, linewidth = line_size) +
  geom_path(data = b_ell_lda_1_5, aes(x = x1, y = x2), color = "#4DA6DA", alpha = 0.6, linewidth = line_size) +
  geom_path(data = b_ell_lda_2, aes(x = x1, y = x2), color = "#4DA6DA", alpha = 0.6, linewidth = line_size) +
  labs(x = expression(x[1]), y = expression(x[2])) +
  coord_fixed(ratio = 0.5) +
  theme_minimal(base_size = base_size) +
  scale_color_manual(values = c("a" = "#E69F00", "b" = "#4DA6DA"))

plot_lda_2 <- ggplot(data = df_lda, aes(x = x1, y = x2, color = y)) +
  geom_point(size = point_size, show.legend = TRUE) +
  geom_path(data = a_ell_lda_1, aes(x = x1, y = x2), color = "#E69F00", alpha = 0.6, linewidth = line_size) +
  geom_path(data = a_ell_lda_1_5, aes(x = x1, y = x2), color = "#E69F00", alpha = 0.6, linewidth = line_size) +
  geom_path(data = a_ell_lda_2, aes(x = x1, y = x2), color = "#E69F00", alpha = 0.6, linewidth = line_size) +
  geom_path(data = b_ell_lda_1, aes(x = x1, y = x2), color = "#4DA6DA", alpha = 0.6, linewidth = line_size) +
  geom_path(data = b_ell_lda_1_5, aes(x = x1, y = x2), color = "#4DA6DA", alpha = 0.6, linewidth = line_size) +
  geom_path(data = b_ell_lda_2, aes(x = x1, y = x2), color = "#4DA6DA", alpha = 0.6, linewidth = line_size) +
  annotate("text", x = mu_a_lda[1], y = mu_a_lda[2], label = "μ", color = "black", size = point_size * 4, fontface = "bold", hjust = 0.5, vjust = 0.5) +
  annotate("text", x = mu_b_lda[1], y = mu_b_lda[2], label = "μ", color = "black", size = point_size * 4, fontface = "bold", hjust = 0.5, vjust = 0.5) +
#  annotate("segment", x = mu_a_lda[1], y = mu_a_lda[2], xend = mu_a_lda[1] + eigen(var_lda)$vectors[1, 1] * sqrt(eigen(var_lda)$values[1]) * 2, yend = mu_a_lda[2] + eigen(var_lda)$vectors[2, 1] * sqrt(eigen(var_lda)$values[1]) * 2, color = "black", linetype = "dashed", linewidth = line_size * 0.8) +
#  annotate("segment", x = mu_a_lda[1], y = mu_a_lda[2], xend = mu_a_lda[1] + eigen(var_lda)$vectors[1, 2] * sqrt(eigen(var_lda)$values[2]) * 2, yend = mu_a_lda[2] + eigen(var_lda)$vectors[2, 2] * sqrt(eigen(var_lda)$values[2]) * 2, color = "black", linetype = "dashed", linewidth = line_size * 0.8) +
#  annotate("segment", x = mu_b_lda[1], y = mu_b_lda[2], xend = mu_b_lda[1] + eigen(var_lda)$vectors[1, 1] * sqrt(eigen(var_lda)$values[1]) * 2, yend = mu_b_lda[2] + eigen(var_lda)$vectors[2, 1] * sqrt(eigen(var_lda)$values[1]) * 2, color = "black", linetype = "dashed", linewidth = line_size * 0.8) +
#  annotate("segment", x = mu_b_lda[1], y = mu_b_lda[2], xend = mu_b_lda[1] + eigen(var_lda)$vectors[1, 2] * sqrt(eigen(var_lda)$values[2]) * 2, yend = mu_b_lda[2] + eigen(var_lda)$vectors[2, 2] * sqrt(eigen(var_lda)$values[2]) * 2, color = "black", linetype = "dashed", linewidth = line_size * 0.8) +
  labs(x = expression(x[1]), y = expression(x[2])) +
  coord_fixed(ratio = 0.5) +
  theme_minimal(base_size = base_size) +
  scale_color_manual(values = c("a" = "#E69F00", "b" = "#4DA6DA"))

plot_qda_1 <- ggplot(data = df_qda, aes(x = x1, y = x2, color = y)) +
  geom_point(size = point_size, show.legend = TRUE) +
  geom_path(data = a_ell_qda_1, aes(x = x1, y = x2), color = "#E69F00", alpha = 0.6, linewidth = line_size) +
  geom_path(data = a_ell_qda_1_5, aes(x = x1, y = x2), color = "#E69F00", alpha = 0.6, linewidth = line_size) +
  geom_path(data = a_ell_qda_2, aes(x = x1, y = x2), color = "#E69F00", alpha = 0.6, linewidth = line_size) +
  geom_path(data = b_ell_qda_1, aes(x = x1, y = x2), color = "#4DA6DA", alpha = 0.6, linewidth = line_size) +
  geom_path(data = b_ell_qda_1_5, aes(x = x1, y = x2), color = "#4DA6DA", alpha = 0.6, linewidth = line_size) +
  geom_path(data = b_ell_qda_2, aes(x = x1, y = x2), color = "#4DA6DA", alpha = 0.6, linewidth = line_size) +
  geom_path(data = c_ell_qda_1, aes(x = x1, y = x2), color = "#009E73", alpha = 0.6, linewidth = line_size) +
  geom_path(data = c_ell_qda_1_5, aes(x = x1, y = x2), color = "#009E73", alpha = 0.6, linewidth = line_size) +
  geom_path(data = c_ell_qda_2, aes(x = x1, y = x2), color = "#009E73", alpha = 0.6, linewidth = line_size) +
  labs(x = expression(x[1]), y = expression(x[2])) +
  coord_fixed(ratio = 0.5) +
  theme_minimal(base_size = base_size) +
  scale_color_manual(values = c("a" = "#E69F00", "b" = "#4DA6DA", "c" = "#009E73"))

plot_qda_2 <- ggplot(data = df_qda, aes(x = x1, y = x2, color = y)) +
  geom_point(size = point_size, show.legend = TRUE) +
  geom_path(data = a_ell_qda_1, aes(x = x1, y = x2), color = "#E69F00", alpha = 0.6, linewidth = line_size) +
  geom_path(data = a_ell_qda_1_5, aes(x = x1, y = x2), color = "#E69F00", alpha = 0.6, linewidth = line_size) +
  geom_path(data = a_ell_qda_2, aes(x = x1, y = x2), color = "#E69F00", alpha = 0.6, linewidth = line_size) +
  geom_path(data = b_ell_qda_1, aes(x = x1, y = x2), color = "#4DA6DA", alpha = 0.6, linewidth = line_size) +
  geom_path(data = b_ell_qda_1_5, aes(x = x1, y = x2), color = "#4DA6DA", alpha = 0.6, linewidth = line_size) +
  geom_path(data = b_ell_qda_2, aes(x = x1, y = x2), color = "#4DA6DA", alpha = 0.6, linewidth = line_size) +
  geom_path(data = c_ell_qda_1, aes(x = x1, y = x2), color = "#009E73", alpha = 0.6, linewidth = line_size) +
  geom_path(data = c_ell_qda_1_5, aes(x = x1, y = x2), color = "#009E73", alpha = 0.6, linewidth = line_size) +
  geom_path(data = c_ell_qda_2, aes(x = x1, y = x2), color = "#009E73", alpha = 0.6, linewidth = line_size) +
  annotate("text", x = mu_a_qda[1], y = mu_a_qda[2], label = "μ", color = "black", size = point_size * 4, fontface = "bold", hjust = 0.5, vjust = 0.5) +
  annotate("text", x = mu_b_qda[1], y = mu_b_qda[2], label = "μ", color = "black", size = point_size * 4, fontface = "bold", hjust = 0.5, vjust = 0.5) +
  annotate("text", x = mu_c_qda[1], y = mu_c_qda[2], label = "μ", color = "black", size = point_size * 4, fontface = "bold", hjust = 0.5, vjust = 0.5) +
#  annotate("segment", x = mu_a_qda[1], y = mu_a_qda[2], xend = mu_a_qda[1] + eigen(var_qda_a)$vectors[1, 1] * sqrt(eigen(var_qda_a)$values[1]) * 2, yend = mu_a_qda[2] + eigen(var_qda_a)$vectors[2, 1] * sqrt(eigen(var_qda_a)$values[1]) * 2, color = "black", linetype = "dashed", linewidth = line_size * 0.8) +
#  annotate("segment", x = mu_a_qda[1], y = mu_a_qda[2], xend = mu_a_qda[1] + eigen(var_qda_a)$vectors[1, 2] * sqrt(eigen(var_qda_a)$values[2]) * 2, yend = mu_a_qda[2] + eigen(var_qda_a)$vectors[2, 2] * sqrt(eigen(var_qda_a)$values[2]) * 2, color = "black", linetype = "dashed", linewidth = line_size * 0.8) +
#  annotate("segment", x = mu_b_qda[1], y = mu_b_qda[2], xend = mu_b_qda[1] + eigen(var_qda_b)$vectors[1, 1] * sqrt(eigen(var_qda_b)$values[1]) * 2, yend = mu_b_qda[2] + eigen(var_qda_b)$vectors[2, 1] * sqrt(eigen(var_qda_b)$values[1]) * 2, color = "black", linetype = "dashed", linewidth = line_size * 0.8) +
#  annotate("segment", x = mu_b_qda[1], y = mu_b_qda[2], xend = mu_b_qda[1] + eigen(var_qda_b)$vectors[1, 2] * sqrt(eigen(var_qda_b)$values[2]) * 2, yend = mu_b_qda[2] + eigen(var_qda_b)$vectors[2, 2] * sqrt(eigen(var_qda_b)$values[2]) * 2, color = "black", linetype = "dashed", linewidth = line_size * 0.8) +
#  annotate("segment", x = mu_c_qda[1], y = mu_c_qda[2], xend = mu_c_qda[1] + eigen(var_qda_c)$vectors[1, 1] * sqrt(eigen(var_qda_c)$values[1]) * 2, yend = mu_c_qda[2] + eigen(var_qda_c)$vectors[2, 1] * sqrt(eigen(var_qda_c)$values[1]) * 2, color = "black", linetype = "dashed", linewidth = line_size * 0.8) +
#  annotate("segment", x = mu_c_qda[1], y = mu_c_qda[2], xend = mu_c_qda[1] + eigen(var_qda_c)$vectors[1, 2] * sqrt(eigen(var_qda_c)$values[2]) * 2, yend = mu_c_qda[2] + eigen(var_qda_c)$vectors[2, 2] * sqrt(eigen(var_qda_c)$values[2]) * 2, color = "black", linetype = "dashed", linewidth = line_size * 0.8) +
  labs(x = expression(x[1]), y = expression(x[2])) +
  coord_fixed(ratio = 0.5) +
  theme_minimal(base_size = base_size) +
  scale_color_manual(values = c("a" = "#E69F00", "b" = "#4DA6DA", "c" = "#009E73"))

ggsave("../figure/disc_analysis-lda_1.png", plot = plot_lda_1, width = plot_width, height = plot_height, dpi = plot_dpi)
ggsave("../figure/disc_analysis-lda_2.png", plot = plot_lda_2, width = plot_width, height = plot_height, dpi = plot_dpi)
ggsave("../figure/disc_analysis-qda_1.png", plot = plot_qda_1, width = plot_width, height = plot_height, dpi = plot_dpi)
ggsave("../figure/disc_analysis-qda_2.png", plot = plot_qda_2, width = plot_width, height = plot_height, dpi = plot_dpi)
