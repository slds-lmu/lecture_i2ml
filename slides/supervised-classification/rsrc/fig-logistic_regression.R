# goal here is to create clean visualizations for the logistic function / logits for the logistic regression chunk
library(ggplot2)

# OPTIONS
plot_width <- 21
plot_height <- 7
plot_dpi <- 300
line_size <- 5
base_size <- 28
color_palette <- c("Standard Logistic" = "black", "Shift Right (2)" = "orange", "Shift Left (-2)" = "deepskyblue3", "Slope = 0.4" = "darkgreen", "Slope = -5" = "firebrick", "Slope = -1" = "purple")

# DEFINITIONS
logistic <- function(x) { 1 / (1 + exp(-x)) }
logistic_shifted <- function(x, shift) { 1 / (1 + exp(-(x - shift))) }
logistic_scaled <- function(x, slope) { 1 / (1 + exp(-slope * x)) }
logit <- function(y) { log(y / (1 - y)) }

# PLOTTING DATA
x <- seq(-10, 10, length.out = 100)
y <- seq(0.01, 0.99, length.out = 100)  # To avoid logit issues at 0 and 1

# plot 1: standard logistic function
data_logistic <- data.frame(x = x, y = logistic(x))
p1 <- ggplot(data_logistic, aes(x, y)) +
  geom_line(size = line_size, color = "black") +
  labs(x = "x", y = "f(x)") +
  theme_minimal(base_size = base_size)
p1

# plot 2: shifted logistic function
data_shifted <- data.frame(
  x = rep(x, 3),
  y = c(logistic_shifted(x, 2), logistic_shifted(x, -2), logistic(x)),
  Shift = rep(c("Shift Right (2)", "Shift Left (-2)", "Standard Logistic"), each = length(x))
)
p2 <- ggplot(data_shifted, aes(x, y, color = Shift)) +
  geom_line(size = line_size) +
  scale_color_manual(values = color_palette) +
  labs(x = "x", y = "f(x)") +
  theme_minimal(base_size = base_size)
p2

# plot 3: scaled logistic function
data_scaled <- data.frame(
  x = rep(x, 4),
  y = c(logistic_scaled(x, 0.4), logistic_scaled(x, 5), logistic(x), logistic_scaled(x, -1)),
  Slope = rep(c("Slope = 0.4", "Slope = -5", "Standard Logistic", "Slope = -1"), each = length(x))
)
p3 <- ggplot(data_scaled, aes(x, y, color = Slope)) +
  geom_line(size = line_size) +
  scale_color_manual(values = color_palette) +
  labs(x = "x", y = "f(x)") +
  theme_minimal(base_size = base_size)
p3

# plot 4: logit
data_logit <- data.frame(y = y, logit_y = logit(y))
p4 <- ggplot(data_logit, aes(y, logit_y)) +
  geom_line(size = line_size) +
  labs(x = "p", y = "logit(p)") +
  theme_minimal(base_size = base_size)
p4

# SAVE PLOTS
plots <- list(p1, p2, p3, p4)
plot_titles <- c("../figure/logistic_function.png", "../figure/logistic_shifted.png", "../figure/logistic_scaled.png", "../figure/logit_function.png")

for (i in 1:4) {
  ggsave(plot_titles[i], plot = plots[[i]], width = plot_width, height = plot_height, dpi = plot_dpi)
}
