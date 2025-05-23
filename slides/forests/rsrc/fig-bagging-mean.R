# we want to visualize how bagging works, e.g.
# that the predicitions of the base learners are averaged
# -> creates 100 trees on bootstrapped toy data; visualizes them with their respective average
# additionally, plots ntrees vs MSE to show benefits of large examples

library(ggplot2)
library(rpart)
library(gridExtra)

set.seed(700)

# Generate toy data
n <- 700
x <- runif(n, 0, 10)
y <- sin(x) + rnorm(n, sd=0.6)
data <- data.frame(x=x, y=y)

# Fit data on bootstrapped toy data
num_trees <- 100
trees <- lapply(1:num_trees, function(i) {
  samp <- sample(n, replace=TRUE)
  rpart(y ~ x, data=data[samp,], method="anova")
})
x_seq <- seq(0, 10, length.out=250)
preds <- sapply(trees, function(tree) predict(tree, newdata=data.frame(x=x_seq)))

# Mean acquired via bagging
mean_preds <- rowMeans(preds)

# Combined into a dataframe for plotting
plot_df <- data.frame(x = rep(x_seq, each = num_trees + 1), 
                      y = c(t(preds), mean_preds),
                      Model = factor(c(rep("individual trees", num_trees), "bagged mean")))

# Visualization of toy data
p1 <- ggplot(data, aes(x=x, y=y)) +
  geom_point(alpha=0.5) +
  stat_function(fun = sin, color = "red") +
  theme_minimal(base_size = 33)

# visualization of tree's predictions and mean (bagged)
p2 <- ggplot(plot_df, aes(x=x, y=y, color=Model)) +
  geom_line(alpha=0.3) +
  geom_line(data = subset(plot_df, Model == "bagged mean"), size=1.0) +
  theme_minimal(base_size = 33)

# function to calculate MSE for different numbers of trees
bagging_rpart <- function(data, num_trees, sample_size) {
  predictions <- matrix(NA, nrow = nrow(data), ncol = num_trees)
  
  for (i in 1:num_trees) {
    sample_indices <- sample(nrow(data), size = sample_size, replace = TRUE)
    sample_data <- data[sample_indices, ]
    
    model <- rpart(y ~ x, data = sample_data)
    
    predictions[, i] <- predict(model, data)
  }
  
  mean_predictions <- rowMeans(predictions, na.rm = TRUE)
  error <- mean((mean_predictions - data$y)^2)
  
  return(error)
}

# calculate MSE for different numbers of trees using the toy data
results <- data.frame(Number_of_Trees = integer(), MSE = numeric())
tree_counts <- seq(1, num_trees, by = 2)

for (trees in tree_counts) {
  mse <- bagging_rpart(data, num_trees = trees, sample_size = 700)
  results <- rbind(results, data.frame(Number_of_Trees = trees, MSE = mse))
}

# plot MSE vs. number of trees
p3 <- ggplot(results, aes(x = Number_of_Trees, y = MSE)) +
  geom_line(color = "blue", size = 1.5) +
  labs(x = "number of decision trees",
       y = "MSE on training data") +
  theme_minimal(base_size = 33)

combined_plot <- grid.arrange(p3, p1, p2, ncol=3, nrow=1, widths=c(1, 1, 1.35)) # so all plots are roughly the same width

ggsave("../figure/bagging-mean.png", plot = combined_plot, width = 30, height = 8, dpi = 300)
