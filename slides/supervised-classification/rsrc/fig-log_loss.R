# here, we create a simple but clean visualization of the log loss. We first define the log loss,
# use it to create some sample data, and plot it!
library(ggplot2)

# OPTIONS
plot_width <- 21
plot_height <- 7
plot_dpi <- 300
line_size <- 5
base_size <- 32

log_loss <- function(y, p) {
  ifelse(y == 1, -log(p), -log(1 - p))
}

p_vals <- seq(0.01, 0.99, by = 0.01)
y_0 <- sapply(p_vals, function(p) log_loss(0, p))
y_1 <- sapply(p_vals, function(p) log_loss(1, p))

data <- data.frame(
  p = rep(p_vals, 2),
  loss = c(y_0, y_1),
  y = factor(rep(c(0, 1), each = length(p_vals)))
)

ggplot(data, aes(x = p, y = loss, color = y)) +
  geom_line(size = line_size) +
  scale_color_manual(values = c("#0072B2", "#E69F00")) +  # Dark blue and orange
  labs(
    x = expression(pi(x)),
    y = expression(L(y, pi(x))),
    color = "y"
  ) +
  theme_minimal(base_size = base_size) +
  theme(
    legend.position = "right",
    legend.text = element_text(size = 35),
    legend.title = element_text(size = 40),
    panel.grid.minor = element_blank()
  ) +
  annotate("text", x = 0.05, y = 4, label = "wrong", color = "#E69F00", size = 20, hjust = 0) +
  annotate("text", x = 0.95, y = 4, label = "wrong", color = "#0072B2", size = 20, hjust = 1) +
  annotate("text", x = 0.05, y = 0.8, label = "right", color = "#0072B2", size = 20, hjust = 0) +
  annotate("text", x = 0.95, y = 0.8, label = "right", color = "#E69F00", size = 20, hjust = 1)

ggsave("../figure/log_loss.png", width = plot_width, height = plot_height, dpi = plot_dpi)


ggsave("../figure/log_loss.png", width = plot_width, height = plot_height, dpi = plot_dpi)
