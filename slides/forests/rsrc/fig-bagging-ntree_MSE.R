library(ggplot2)
library(rpart)

set.seed(11)

n <- 500 # num of obs
X <- runif(n)
y <- sin(2 * pi * X) + rnorm(n, sd = 0.1)
data <- data.frame(X = X, Y = y)

bagging_rpart <- function(data, num_trees, sample_size) {
  predictions <- matrix(NA, nrow = nrow(data), ncol = num_trees)
  
  for (i in 1:num_trees) {
    #  bootstrap sample generator
    sample_indices <- sample(nrow(data), size = sample_size, replace = TRUE)
    sample_data <- data[sample_indices, ]
    
    model <- rpart(Y ~ X, data = sample_data)
    
    predictions[, i] <- predict(model, data)
  }
  
  mean_predictions <- rowMeans(predictions, na.rm = TRUE)
  error <- mean((mean_predictions - data$Y)^2)
  
  return(error)
}

results <- data.frame(Number_of_Trees = integer(), MSE = numeric())
tree_counts <- seq(1, 200, by = 2)

for (trees in tree_counts) {
  mse <- bagging_rpart(data, num_trees = trees, sample_size = 500)
  results <- rbind(results, data.frame(Number_of_Trees = trees, MSE = mse))
}

p <- ggplot(results, aes(x = Number_of_Trees, y = MSE)) +
  geom_line(color = "blue", size = 1.5) +
  labs(x = "Number of decision trees",
       y = "Mean Squared Error") +
  theme_minimal()

ggsave("bagging-ntree_MSE.png", plot = p, width = 16, height = 8, dpi = 300)
