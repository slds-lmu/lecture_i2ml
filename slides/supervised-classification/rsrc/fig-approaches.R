library(ggplot2)
library(MASS)
library(plotly)
set.seed(123)

# generate synthetic data for two classes (Gaussian distribution)
class1 <- mvrnorm(n = 100, mu = c(2, 2), Sigma = matrix(c(1, 0.5, 0.5, 1), ncol = 2))
class2 <- mvrnorm(n = 100, mu = c(-2, -2), Sigma = matrix(c(1, -0.5, -0.5, 1), ncol = 2))

# combine into a data frame
data <- data.frame(rbind(class1, class2))
names(data) <- c("X1", "X2")
data$class <- factor(rep(c(1, 2), each = 100))

# Normalize features X1 and X2
data$X1 <- as.numeric(scale(data$X1))
data$X2 <- as.numeric(scale(data$X2))


# ----GENERATIVE APPROACH----

# generate grid for density estimation
x_range <- seq(min(data$X1) - 1, max(data$X1) + 1, length.out = 100)
y_range <- seq(min(data$X2) - 1, max(data$X2) + 1, length.out = 100)
grid <- expand.grid(X1 = x_range, X2 = y_range)

# fit Naive Bayes style Gaussian for each class (density estimation) using scaled data
dens_class1 <- kde2d(data$X1[data$class == 1], data$X2[data$class == 1], n = 100, lims = c(range(x_range), range(y_range)))
dens_class2 <- kde2d(data$X1[data$class == 2], data$X2[data$class == 2], n = 100, lims = c(range(x_range), range(y_range)))

# converts densities to data frames for ggplot
dens_df1 <- data.frame(expand.grid(X1 = dens_class1$x, X2 = dens_class1$y), z = as.vector(dens_class1$z))
dens_df2 <- data.frame(expand.grid(X1 = dens_class2$x, X2 = dens_class2$y), z = as.vector(dens_class2$z))

# plot the data with Gaussian PDFs
p_generative <- ggplot(data, aes(x = X1, y = X2, color = class)) +
  geom_point(size = 2) +
  geom_contour(data = dens_df1, aes(x = X1, y = X2, z = z), color = "red", alpha = 0.5) +
  geom_contour(data = dens_df2, aes(x = X1, y = X2, z = z), color = "blue", alpha = 0.5) +
  labs(x = 'feature 1', y = 'feature 2') +
  theme_minimal()
print(p_generative)


# ----DISCRIMINANT APPROACH----

# plot the data with a few candidate decision boundaries
p_candidates <- ggplot(data, aes(x = X1, y = X2, color = class)) +
  geom_point(size = 2) +
  # Add candidate decision boundaries (more accurate guesses)
  geom_abline(intercept = -0.5, slope = -0.5, color = "grey", linetype = "dashed") +  # Candidate boundary 1
  geom_abline(intercept = -0.25, slope = -1.2, color = "grey", linetype = "dashed") +  # Candidate boundary 2
  geom_abline(intercept = -1, slope = -1.6, color = "grey", linetype = "dashed") +  # Candidate boundary 3
  labs(x = 'Feature 1', y = 'Feature 2', title = 'Candidate Hypotheses (Decision Boundaries)') +
  theme_minimal() +
  scale_color_manual(values = c("#00BFC4", "#F8766D"))

print(p_candidates)

# ----LOSS LANDSCAPE----

# Create a grid of parameter values
intercepts <- seq(-10, 10, length.out = 100)  # Extended range of intercepts for clearer effect
slope_x1 <- seq(-5, 5, length.out = 100)  # Increased resolution for slopes
slope_x2 <- seq(-5, 5, length.out = 100)
loss_matrix <- array(NA, dim = c(length(intercepts), length(slope_x1), length(slope_x2)))

# Calculate the loss for each combination of intercept, slope_x1, and slope_x2
for (i in 1:length(intercepts)) {
  for (j in 1:length(slope_x1)) {
    for (k in 1:length(slope_x2)) {
      intercept <- intercepts[i]
      slope1 <- slope_x1[j]
      slope2 <- slope_x2[k]
      linear_combination <- intercept + slope1 * data$X1 + slope2 * data$X2
      predicted_probs <- 1 / (1 + exp(-linear_combination))
      predicted_probs <- pmin(pmax(predicted_probs, 1e-15), 1 - 1e-15)  # Clipping predicted_probs to avoid log(0)
      loss <- -mean(ifelse(data$class == 1, log(predicted_probs), log(1 - predicted_probs)))
      loss_matrix[i, j, k] <- loss
    }
  }
}

# Convert loss_matrix to a data frame for plotting (taking a slice for fixed Slope_X2 = 2.47)
slice_index <- which.min(abs(slope_x2 - 2.47))  # Find the closest index for Slope_X2 = 2.47
loss_data <- expand.grid(Intercept = intercepts, Slope_X1 = slope_x1)
loss_data$Loss <- as.vector(loss_matrix[, , slice_index])

# Remove rows with NA values for plotting
loss_data <- loss_data[!is.na(loss_data$Loss), ]

# Plot the loss landscape using plotly
loss_plot <- plot_ly(z = matrix(loss_data$Loss, nrow = length(intercepts), byrow = TRUE),
                     x = intercepts,
                     y = slope_x1,
                     type = "surface") %>%
  layout(title = "Loss Landscape (Fixed Slope_X2 = 2.47)",
         scene = list(xaxis = list(title = "Intercept"),
                      yaxis = list(title = "Slope_X1"),
                      zaxis = list(title = "Loss")))

print(loss_plot)

# fit a logistic regression model for the discriminant approach
logistic_model <- glm(class ~ X1 + X2, data = data, family = binomial)

# Create a grid for prediction
grid_x1 <- seq(min(data$X1) - 1, max(data$X1) + 1, length.out = 100)
grid_x2 <- seq(min(data$X2) - 1, max(data$X2) + 1, length.out = 100)
grid <- expand.grid(X1 = grid_x1, X2 = grid_x2)

# Convert grid features to numeric to match data types in model
grid$X1 <- as.numeric(grid$X1)
grid$X2 <- as.numeric(grid$X2)

# predict class probabilities on the grid
grid$pred_prob <- predict(logistic_model, newdata = grid, type = "response")
grid$pred_class <- ifelse(grid$pred_prob > 0.5, 1, 2)

p_discriminative <- ggplot(data, aes(x = X1, y = X2, color = class)) +
  geom_point(size = 2) +
  geom_contour(data = grid, aes(x = X1, y = X2, z = pred_prob), color = "black", alpha = 0.5) +
  labs(x = 'feature 1', y = 'feature 2') +
  theme_minimal()
print(p_discriminative)

# ----SAVE THE PLOTS----

ggsave("figure/approach_generative", plot = p_generative, width = 8, height = 8)
ggsave("figure/approach_discriminant", plot = p_discriminative, width = 8, height = 8)