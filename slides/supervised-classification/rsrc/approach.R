
library(ggplot2)
library(MASS)
set.seed(123)

# generate synthetic data for two classes (Gaussian distribution)
class1 <- mvrnorm(n = 100, mu = c(2, 2), Sigma = matrix(c(1, 0.5, 0.5, 1), ncol = 2))
class2 <- mvrnorm(n = 100, mu = c(-2, -2), Sigma = matrix(c(1, -0.5, -0.5, 1), ncol = 2))

# combine into a data frame
data <- data.frame(rbind(class1, class2))
data$class <- factor(rep(c(1, 2), each = 100))

# ----GENERATIVE APPROACH----

# generate grid for density estimation
x_range <- seq(min(data$X1) - 1, max(data$X1) + 1, length.out = 100)
y_range <- seq(min(data$X2) - 1, max(data$X2) + 1, length.out = 100)
grid <- expand.grid(X1 = x_range, X2 = y_range)

# fit Naive Bayes style Gaussian for each class (density estimation)
dens_class1 <- kde2d(class1[, 1], class1[, 2], n = 100, lims = c(range(x_range), range(y_range)))
dens_class2 <- kde2d(class2[, 1], class2[, 2], n = 100, lims = c(range(x_range), range(y_range)))

# converts densities to data frames for ggplot
dens_df1 <- data.frame(expand.grid(X1 = dens_class1$x, X2 = dens_class1$y), z = as.vector(dens_class1$z))
dens_df2 <- data.frame(expand.grid(X1 = dens_class2$x, X2 = dens_class2$y), z = as.vector(dens_class2$z))

# plot the data with Gaussian PDFs
p_generative <- ggplot(data, aes(x = X1, y = X2, color = class)) +
  geom_point(size = 2) +
  geom_contour(data = dens_df1, aes(x = X1, y = X2, z = z), color = "red", alpha = 0.5) +
  geom_contour(data = dens_df2, aes(x = X1, y = X2, z = z), color = "blue", alpha = 0.5) +
  labs(x = 'Feature 1', y = 'Feature 2') +
  theme_minimal()
print(p_generative)

# ----DISCRIMINANT APPROACH----

# fit a logistic regression model for the discriminant approach
logistic_model <- glm(class ~ X1 + X2, data = data, family = binomial)

# predict class probabilities on the grid
grid$pred_prob <- predict(logistic_model, newdata = grid, type = "response")
grid$pred_class <- ifelse(grid$pred_prob > 0.5, 1, 2)

p_discriminative <- ggplot(data, aes(x = X1, y = X2, color = class)) +
  geom_point(size = 2) +
  geom_contour(data = grid, aes(x = X1, y = X2, z = pred_prob), color = "black", alpha = 0.5) +
  labs(x = 'Feature 1', y = 'Feature 2') +
  theme_minimal()
print(p_discriminative)
 
# ----SAVE THE PLOTS----
ggsave("figure/approach_generative", plot = p_generative, width = 8, height = 8)
ggsave("figure/approach_discriminant", plot = p_discriminative, width = 8, height = 8)
