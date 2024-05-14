library(rpart)
library(ipred)
library(ggplot2)
library(viridis)

set.seed(111)

n <- 100
x <- runif(n)
y <- sin(2 * pi * x) + rnorm(n, 0, 0.9)
data <- data.frame(x = x, y = y)

trees <- list()
bias_values <- c(0.5, -0.5, 0.3, -0.3, 0)

for (i in 1:5) {
  # increasing randomness by adding noise to the bootstrapped samples
  boot_data <- data[sample(1:n, replace = TRUE), ]
  boot_data$y <- boot_data$y + rnorm(nrow(boot_data), 0, 0.1) + bias_values[i]  # manually adding bias for trees
  
  tree <- rpart(y ~ x, data = boot_data, control = rpart.control(cp = 0.01 * i)) # Vary the complexity parameter
  
  # prune the tree for diversity
  prune_tree <- prune(tree, cp = 0.01 * i)
  trees[[i]] <- prune_tree
}

bagged_model <- bagging(y ~ x, data = data, nbagg = 5)

x_seq <- seq(0, 1, length.out = 100)
preds <- data.frame(x = x_seq)

for (i in 1:5) {
  preds[[paste0("tree_", i)]] <- predict(trees[[i]], newdata = data.frame(x = x_seq))
}

preds$bagged <- predict(bagged_model, newdata = data.frame(x = x_seq))

# melt the predictions data frame for easier plotting
preds_long <- preds %>%
  pivot_longer(cols = starts_with("tree_") | ends_with("bagged"), names_to = "model", values_to = "y_pred") %>%
  mutate(model = factor(model, levels = c("tree_1", "tree_2", "tree_3", "tree_4", "tree_5", "bagged")))

colors <- viridis(5, alpha = 0.5)
colors <- c(colors, "black")

ggplot(data, aes(x = x, y = y)) +
  geom_point(alpha = 0.5, size = 3) +
  geom_line(data = preds_long, aes(x = x, y = y_pred, color = model), size = 1.5) + 
  scale_color_manual(values = colors) +
  labs(x = "x",
       y = "y",
       color = "Model") +
  theme_minimal(base_size = 15) +
  theme(
    plot.title = element_text(size = 20),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 12),
    legend.title = element_text(size = 15),
    legend.text = element_text(size = 12)
  )
