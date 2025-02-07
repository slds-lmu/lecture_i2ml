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

# compute the decision boundary based on log likelihood ratio (densities)
dens_diff <- dens_class1$z - dens_class2$z
boundary_df <- data.frame(expand.grid(X1 = dens_class1$x, X2 = dens_class1$y), z = as.vector(dens_diff))

# plot the data with Gaussian PDFs and decision boundary
p_generative <- ggplot(data, aes(x = X1, y = X2, color = class)) +
  geom_point(size = 5) +
  geom_contour(data = dens_df1, aes(x = X1, y = X2, z = z), color = "blue", linewidth = 2, alpha = 0.5) +
  geom_contour(data = dens_df2, aes(x = X1, y = X2, z = z), color = "orange", linewidth = 2, alpha = 0.5) +
  geom_contour(data = boundary_df, aes(x = X1, y = X2, z = z), breaks = 0, color = "black", linewidth = 2, linetype = "dashed") +
  labs(x = 'feature 1', y = 'feature 2') +
  theme_minimal() +
  scale_color_manual(values = c("blue", "orange")) +
  theme(
    axis.title = element_text(size=28),
    axis.text = element_text(size = 22),
    legend.title = element_text(size = 28),
    legend.text = element_text(size = 28)
  )

print(p_generative)

# ----DISCRIMINANT APPROACH----

# plot the data with a few candidate decision boundaries
p_candidates <- ggplot(data, aes(x = X1, y = X2, color = class)) +
  geom_point(size = 4) +
  # adds some candidate decision boundaries
  geom_abline(intercept = -0.2, slope = -0.5, color = "black", linetype = "dashed", size = 1) +
  geom_abline(intercept = -0.25, slope = -1.2, color = "black", linetype = "dashed", size = 1) +
  geom_abline(intercept = -0.2, slope = -2.7, color = "black", linetype = "dashed", size = 1) +
  labs(x = 'feature 1', y = 'feature 2', title = 'candidate hypotheses (decision boundaries)') +
  theme_minimal() +
  scale_color_manual(values = c("blue", "orange")) +
  theme(
    plot.title = element_text(size = 18, hjust = 0.5),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12),
    legend.title = element_text(size = 14),
    legend.text = element_text(size = 12)
  )

print(p_candidates)

# ----LOSS LANDSCAPE----

# creates a grid of parameter values to calculate respective losses
intercepts <- seq(-10, 10, length.out = 100)
slope_x1 <- seq(-5, 5, length.out = 100)
slope_x2 <- seq(-5, 5, length.out = 100)
loss_matrix <- array(NA, dim = c(length(intercepts), length(slope_x1), length(slope_x2)))

# calculates the log loss for each combination of intercept, slope_x1, and slope_x2
for (i in 1:length(intercepts)) {
  for (j in 1:length(slope_x1)) {
    for (k in 1:length(slope_x2)) {
      intercept <- intercepts[i]
      slope1 <- slope_x1[j]
      slope2 <- slope_x2[k]
      linear_combination <- intercept + slope1 * data$X1 + slope2 * data$X2
      predicted_probs <- 1 / (1 + exp(-linear_combination))
      predicted_probs <- pmin(pmax(predicted_probs, 1e-15), 1 - 1e-15)  # clipping predicted_probs to avoid log(0)
      loss <- -mean(ifelse(data$class == 1, log(predicted_probs), log(1 - predicted_probs)))
      loss_matrix[i, j, k] <- loss
    }
  }
}

# we fix the x2 slope to -2.47 to get a pretty landscape!
# converts loss_matrix for plotting, removes NA values
slice_index <- which.min(abs(slope_x2 - 2.47))  # find the closest index for Slope_X2 = -2.47
loss_data <- expand.grid(Intercept = intercepts, Slope_X1 = slope_x1)
loss_data$Loss <- as.vector(loss_matrix[, , slice_index])
loss_data <- loss_data[!is.na(loss_data$Loss), ]

loss_plot <- plot_ly(z = matrix(loss_data$Loss, nrow = length(intercepts), byrow = TRUE),
                     x = intercepts,
                     y = slope_x1,
                     type = "surface",
                     colorscale = "Viridis",
                     colorbar = list(len = 0.7, x = 1.05)) %>%  # adjusts the position of the colorbar
  layout(title = list(text = "loss landscape for &#946;<sub>0</sub> + &#946;<sub>1</sub> x<sub>1</sub> - 2.47 x<sub>2</sub> (fixed &#946;<sub>2</sub> = -2.47)",
                      y = 0.95,
                      font = list(size = 16)),
         scene = list(xaxis = list(title = "intercept"),
                      yaxis = list(title = "slope feature 1"),
                      zaxis = list(title = "log loss")),
         margin = list(t = 40, l = 10, r = 10, b = 10))

print(loss_plot)
# the figure figure_man/loss_plot.png was created manually (to set a good scene!)

# fit a logistic regression model for the discriminant approach
logistic_model <- glm(class ~ X1 + X2, data = data, family = binomial)

# create a grid for prediction
grid_x1 <- seq(min(data$X1) - 1, max(data$X1) + 1, length.out = 100)
grid_x2 <- seq(min(data$X2) - 1, max(data$X2) + 1, length.out = 100)
grid <- expand.grid(X1 = grid_x1, X2 = grid_x2)

# convert grid features to numeric to match data types in model
grid$X1 <- as.numeric(grid$X1)
grid$X2 <- as.numeric(grid$X2)

# predict class probabilities on the grid
grid$pred_prob <- predict(logistic_model, newdata = grid, type = "response")
grid$pred_class <- ifelse(grid$pred_prob > 0.5, 1, 2)

p_discriminative <- ggplot() +
  geom_point(data = data, aes(x = X1, y = X2, color = class), size = 4) +
  geom_tile(data = grid, aes(x = X1, y = X2, fill = pred_prob), alpha = 0.2) +
  geom_contour(data = grid, aes(x = X1, y = X2, z = pred_prob), color = "black", size = 1, alpha = 0.8) + 
  scale_fill_gradient2(low = "blue", high = "orange", mid = "white", midpoint = 0.5) +
  scale_color_manual(values = c("blue", "orange")) +
  labs(x = 'feature 1', y = 'feature 2', title = 'final hypothesis') +
  guides(fill = "none") +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 18, hjust = 0.5),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12),
    legend.title = element_text(size = 14),
    legend.text = element_text(size = 12)
  )

print(p_discriminative)

# ----SAVE THE PLOTS----

ggsave("../figure/approach_generative.png", plot = p_generative, width = 10, height = 8)
ggsave("../figure/approach_disc_candidates.png", plot = p_candidates, width = 8, height = 8)
ggsave("../figure/approach_disc_fitted.png", plot = p_discriminative, width = 8, height = 8)
