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

create_plot <- function(data, ellipses, colors, annotate_means = FALSE, means = NULL) {
  # base plot
  plot <- ggplot(data, aes(x = x1, y = x2, color = y)) +
    geom_point(size = point_size, show.legend = TRUE) +
    labs(x = expression(x[1]), y = expression(x[2]), color = "class") +
    coord_fixed(ratio = 0.5) +
    theme_minimal(base_size = base_size) +
    scale_color_manual(values = colors)
  
  # adding ellipses to the plot
  for (ellipse in ellipses) {
    plot <- plot + geom_path(data = ellipse$data, aes(x = x1, y = x2), 
                             color = ellipse$color, alpha = 0.6, linewidth = line_size)
  }
  
  # adding mean points if annotate_means is TRUE
  if (annotate_means && !is.null(means)) {
    darker_colors <- c("#8B0000", "#003366", "#006400")
    mean_data <- data.frame(x1 = sapply(means, `[[`, "x"), x2 = sapply(means, `[[`, "y"), label = paste0("mean ", names(colors)))
    plot <- plot +
      geom_point(data = mean_data, aes(x = x1, y = x2, color = label), size = point_size * 3, shape = 8, show.legend = TRUE) +
      scale_color_manual(values = c(colors, setNames(darker_colors, mean_data$label))) +
      guides(color = guide_legend(override.aes = list(shape = c(rep(16, length(colors)), rep(8, length(means))))))
  }
  
  return(plot)
}

lda_colors <- c("a" = "#E69F00", "b" = "#56B4E9")
qda_colors <- c("a" = "#E69F00", "b" = "#56B4E9", "c" = "#009E73")

lda_ellipses <- list(
  list(data = a_ell_lda_1, color = "#E69F00"),
  list(data = a_ell_lda_1_5, color = "#E69F00"),
  list(data = a_ell_lda_2, color = "#E69F00"),
  list(data = b_ell_lda_1, color = "#56B4E9"),
  list(data = b_ell_lda_1_5, color = "#56B4E9"),
  list(data = b_ell_lda_2, color = "#56B4E9")
)

qda_ellipses <- list(
  list(data = a_ell_qda_1, color = "#E69F00"),
  list(data = a_ell_qda_1_5, color = "#E69F00"),
  list(data = a_ell_qda_2, color = "#E69F00"),
  list(data = b_ell_qda_1, color = "#56B4E9"),
  list(data = b_ell_qda_1_5, color = "#56B4E9"),
  list(data = b_ell_qda_2, color = "#56B4E9"),
  list(data = c_ell_qda_1, color = "#009E73"),
  list(data = c_ell_qda_1_5, color = "#009E73"),
  list(data = c_ell_qda_2, color = "#009E73")
)

lda_means <- list(list(x = mu_a_lda[1], y = mu_a_lda[2]), list(x = mu_b_lda[1], y = mu_b_lda[2]))
qda_means <- list(list(x = mu_a_qda[1], y = mu_a_qda[2]), list(x = mu_b_qda[1], y = mu_b_qda[2]), list(x = mu_c_qda[1], y = mu_c_qda[2]))

plot_lda_1 <- create_plot(data = df_lda, ellipses = lda_ellipses, colors = lda_colors)
plot_lda_2 <- create_plot(data = df_lda, ellipses = lda_ellipses, colors = lda_colors, annotate_means = TRUE, means = lda_means)

plot_qda_1 <- create_plot(data = df_qda, ellipses = qda_ellipses, colors = qda_colors)
plot_qda_2 <- create_plot(data = df_qda, ellipses = qda_ellipses, colors = qda_colors, annotate_means = TRUE, means = qda_means)

ggsave("../figure/disc_analysis-lda_1.png", plot = plot_lda_1, width = plot_width, height = plot_height, dpi = plot_dpi)
ggsave("../figure/disc_analysis-lda_2.png", plot = plot_lda_2, width = plot_width, height = plot_height, dpi = plot_dpi)
ggsave("../figure/disc_analysis-qda_1.png", plot = plot_qda_1, width = plot_width, height = plot_height, dpi = plot_dpi)
ggsave("../figure/disc_analysis-qda_2.png", plot = plot_qda_2, width = plot_width, height = plot_height, dpi = plot_dpi)
